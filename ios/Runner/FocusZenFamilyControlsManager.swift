import Foundation
import UIKit

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import SwiftUI
#endif

/// iOS Screen Time (FamilyControls) integration.
///
/// Notes:
/// - Requires iOS 16+.
/// - Requires the "Family Controls" capability / entitlement when signing.
/// - This implementation uses a best-effort timer + foreground check to clear shields.
final class FocusZenFamilyControlsManager {
  static let shared = FocusZenFamilyControlsManager()

  private init() {}

  private let blockUntilKey = "focuszen_block_until_epoch_ms"

  #if canImport(FamilyControls)
  @available(iOS 16.0, *)
  private let store = ManagedSettingsStore()

  @available(iOS 16.0, *)
  private let selectionStore = FocusZenSelectionStore()
  #endif

  func isSupported() -> Bool {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) { return true }
    return false
    #else
    return false
    #endif
  }

  func requestAuthorization(completion: @escaping (Bool) -> Void) {
    #if canImport(FamilyControls)
    guard #available(iOS 16.0, *) else {
      completion(false)
      return
    }

    Task {
      do {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        completion(true)
      } catch {
        completion(false)
      }
    }
    #else
    completion(false)
    #endif
  }

  /// Starts shielding. If the user has never selected apps/categories before,
  /// this will present the FamilyActivityPicker.
  func startBlocking(from rootViewController: UIViewController, durationSeconds: Int, completion: @escaping (Result<Void, Error>) -> Void) {
    #if canImport(FamilyControls)
    guard #available(iOS 16.0, *) else {
      completion(.failure(NSError(domain: "FocusZen", code: 1, userInfo: [NSLocalizedDescriptionKey: "iOS 16+ gerekli."])) )
      return
    }

    let applySelection: (FamilyActivitySelection) -> Void = { [weak self] selection in
      guard let self else { return }

      // Apply shields.
      self.store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
      self.store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : .specific(selection.categoryTokens)

      // Persist end time.
      let untilMs = durationSeconds > 0 ? Int64(Date().timeIntervalSince1970 * 1000.0) + Int64(durationSeconds) * 1000 : 0
      UserDefaults.standard.set(untilMs, forKey: self.blockUntilKey)

      completion(.success(()))
    }

    // Use existing selection if available.
    if let existing = selectionStore.loadSelection(), (!existing.applicationTokens.isEmpty || !existing.categoryTokens.isEmpty) {
      applySelection(existing)
      return
    }

    // Present picker to get selection.
    let picker = FocusZenFamilyActivityPickerView(onDone: { [weak self] selection in
      self?.selectionStore.saveSelection(selection)
      applySelection(selection)
    }, onCancel: {
      completion(.failure(NSError(domain: "FocusZen", code: 2, userInfo: [NSLocalizedDescriptionKey: "Uygulama seçimi iptal edildi."])) )
    })

    let host = UIHostingController(rootView: picker)
    host.modalPresentationStyle = .pageSheet
    rootViewController.present(host, animated: true)
    #else
    completion(.failure(NSError(domain: "FocusZen", code: 3, userInfo: [NSLocalizedDescriptionKey: "FamilyControls framework mevcut değil."])) )
    #endif
  }

  func stopBlocking() {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      store.clearAllSettings()
    }
    #endif
    UserDefaults.standard.set(0, forKey: blockUntilKey)
  }

  /// Clears shields if a time-based block has expired (best-effort).
  func clearIfExpired() {
    let untilMs = UserDefaults.standard.object(forKey: blockUntilKey) as? Int64 ?? 0
    guard untilMs > 0 else { return }
    let nowMs = Int64(Date().timeIntervalSince1970 * 1000.0)
    if nowMs > untilMs { stopBlocking() }
  }
}

#if canImport(FamilyControls)
@available(iOS 16.0, *)
private final class FocusZenSelectionStore {
  private let key = "focuszen_family_activity_selection"

  func saveSelection(_ selection: FamilyActivitySelection) {
    do {
      let data = try PropertyListEncoder().encode(selection)
      UserDefaults.standard.set(data, forKey: key)
    } catch {
      // ignore
    }
  }

  func loadSelection() -> FamilyActivitySelection? {
    guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
    return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
  }
}

@available(iOS 16.0, *)
private struct FocusZenFamilyActivityPickerView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var selection = FamilyActivitySelection()

  let onDone: (FamilyActivitySelection) -> Void
  let onCancel: () -> Void

  var body: some View {
    NavigationView {
      FamilyActivityPicker(selection: $selection)
        .navigationTitle("Engellenecek uygulamalar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Vazgeç") {
              dismiss()
              onCancel()
            }
          }
          ToolbarItem(placement: .confirmationAction) {
            Button("Kaydet") {
              dismiss()
              onDone(selection)
            }
          }
        }
    }
  }
}
#endif
