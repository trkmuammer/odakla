import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focuszen/theme.dart';
import 'package:focuszen/services/user_service.dart';
import 'package:focuszen/services/character_service.dart';
import 'package:focuszen/models/character.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedTab = 'characters';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserService>(
      builder: (context, userService, _) {
        final user = userService.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final characters = CharacterService.getAllCharacters();

        return SingleChildScrollView(
          padding: AppSpacing.horizontalLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ödül Mağazası', style: context.textStyles.headlineLarge),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(color: AppColors.darkCardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.cyan, size: 20),
                        const SizedBox(width: 8),
                        Text('${user.points}', style: context.textStyles.titleLarge),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildTabButton(keyName: 'characters', label: 'Karakterler', isSelected: _selectedTab == 'characters'),
                  const SizedBox(width: 16),
                  _buildTabButton(keyName: 'themes', label: 'Temalar', isSelected: _selectedTab == 'themes'),
                ],
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final isUnlocked = user.unlockedCharacters.contains(character.id);
                  final isEquipped = user.equippedCharacter == character.id;
                  
                  return _CharacterCard(
                    character: character,
                    isUnlocked: isUnlocked,
                    isEquipped: isEquipped,
                    userPoints: user.points,
                    onUnlock: () => _unlockCharacter(character),
                    onEquip: () => _equipCharacter(character),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton({required String keyName, required String label, required bool isSelected}) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = keyName),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.darkCard : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: isSelected ? AppColors.darkCardBorder : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: context.textStyles.titleMedium?.copyWith(
                color: isSelected ? AppColors.white : AppColors.ashGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _unlockCharacter(Character character) async {
    final userService = context.read<UserService>();
    final user = userService.currentUser;
    
    if (user == null || user.points < character.pointsCost) {
      _showSnackBar('Yeterli puanın yok!');
      return;
    }
    
    await userService.spendPoints(character.pointsCost);
    await userService.unlockCharacter(character.id);
    await userService.equipCharacter(character.id);
    
    if (mounted) {
      _showSnackBar('${character.name} açıldı ve takıldı!');
    }
  }

  void _equipCharacter(Character character) async {
    final userService = context.read<UserService>();
    await userService.equipCharacter(character.id);
    
    if (mounted) {
      _showSnackBar('${character.name} takıldı!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.darkCard,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final Character character;
  final bool isUnlocked;
  final bool isEquipped;
  final int userPoints;
  final VoidCallback onUnlock;
  final VoidCallback onEquip;

  const _CharacterCard({
    required this.character,
    required this.isUnlocked,
    required this.isEquipped,
    required this.userPoints,
    required this.onUnlock,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isEquipped ? AppColors.purple : AppColors.darkCardBorder,
          width: isEquipped ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isEquipped)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 16),
              ),
            )
          else
            const SizedBox(height: 28),
          Text(character.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(character.name, style: context.textStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(character.description, style: context.textStyles.bodySmall, textAlign: TextAlign.center),
          const Spacer(),
          if (!isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: AppColors.ashGray, size: 16),
                  const SizedBox(width: 6),
                  Text('${character.pointsCost} puan', style: context.textStyles.labelLarge),
                ],
              ),
            )
          else if (isEquipped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Text('Takılı', style: context.textStyles.labelLarge?.copyWith(color: AppColors.white)),
            )
          else
            const SizedBox(height: 32),
          if (!isUnlocked && !character.isDefault)
            const SizedBox(height: 8),
          if (!isUnlocked && !character.isDefault)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: userPoints >= character.pointsCost ? onUnlock : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: AppColors.purple,
                  disabledBackgroundColor: AppColors.darkCardBorder,
                ),
                child: const Text('Aç'),
              ),
            )
          else if (isUnlocked && !isEquipped)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onEquip,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Tak'),
              ),
            ),
        ],
      ),
    );
  }
}
