import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:limit_it_app/controllers/profile_controller.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';
import 'package:limit_it_app/core/helpers/toast_message_helper.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_button.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_loader.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text.dart';
import 'package:limit_it_app/core/presentations/widgets/custom_text_field.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/global/custom_assets/assets.gen.dart';
import '../../../../../core/constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileController profileController = Get.find<ProfileController>();
  
  @override
  void initState() {
    super.initState();
    // Load profile data
    final profile = profileController.userProfile.value;
    if (profile != null) {
      nameCtrl.text = profile.name ?? '';
      emailCtrl.text = profile.email ?? '';
      phoneCtrl.text = profile.phone ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.r),
              onPressed: () => Navigator.pop(context),
            ),
            SizedBox(width: 12.w),
            CustomText(
              text: context.l10n.editProfile,
              color: AppColors.textColor3D3D3D,
              fontsize: 24.sp,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (profileController.profileLoading.value) {
          return const Center(child: CustomLoader());
        }
        
        return _buildProfileContent();
      }),
    );
  }

  Widget _buildProfileContent() {
    return Stack(
      children: [
        Positioned(
          top: 18.h,
          left: 109.w,
          child: Container(
            width: 259.w,
            height: 195.h,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        Container(
          width: 158.w,
          height: 219.h,
          decoration: BoxDecoration(
            color: AppColors.textColor803D20.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24.h),

                /// Profile Image with tap
                GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40.r),
                    child: _pickedImage != null
                        ? Image.file(
                      _pickedImage!,
                      width: 90.w,
                      height: 90.h,
                      fit: BoxFit.cover,
                    )
                        : _buildProfileImageFromController(),
                  ),
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: nameCtrl.text.isNotEmpty ? nameCtrl.text : 'User',
                  fontsize: 24.sp,
                  color: AppColors.textColor1A1A1A,
                ),
                CustomText(
                  text: context.l10n.joinedRecently,
                  fontsize: 12.sp,
                  color: AppColors.textColor5D5D5D,
                ),

                SizedBox(height: 48.h),

                CustomTextField(
                  hintextColor: AppColors.textColor5D5D5D,
                  controller: nameCtrl,
                  hintText: context.l10n.name,
                  prefixIcon: Assets.icons.profileview.svg(),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  hintextColor: AppColors.textColor5D5D5D,
                  controller: phoneCtrl,
                  hintText: context.l10n.phone,
                  prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primaryColor, size: 24.r),
                ),
                SizedBox(height: 16.h),
                CustomTextField(
                  readOnly: true,
                  hintextColor: AppColors.textColor5D5D5D,
                  controller: emailCtrl,
                  hintText: context.l10n.email,
                  prefixIcon: Assets.icons.email.svg(),
                  isEmail: true,
                  // enabled: false,
                ),

                SizedBox(height: 220.h),

                CustomButton(
                  title: context.l10n.updateProfile,
                  onpress: _handleUpdateProfile,
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImageFromController() {
    final profile = profileController.userProfile.value;
    if (profile != null && profile.profilePicture != null && profile.profilePicture!.isNotEmpty) {
      return Image.network(
        profile.profilePicture!,
        width: 90.w,
        height: 90.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            "assets/images/camera.png",
            width: 90.w,
            height: 90.h,
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.asset(
      "assets/images/camera.png",
      width: 90.w,
      height: 90.h,
      fit: BoxFit.cover,
    );
  }

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleUpdateProfile() async {
    // Validate name
    if (nameCtrl.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage(context.l10n.pleaseEnterYourName);
      return;
    }

    // Validate phone
    if (phoneCtrl.text.trim().isEmpty) {
      ToastMessageHelper.showToastMessage(context.l10n.pleaseEnterYourPhone);
      return;
    }

    // Prepare multipart data
    Map<String, String> body = {
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
    };

    List<MultipartBody> multipartBody = [];

    // Add profile picture if selected
    if (_pickedImage != null) {
      multipartBody.add(MultipartBody('profilePicture', _pickedImage!));
    }

    // Call update profile API
    await profileController.updateProfile(
      body: body,
      multipartBody: multipartBody,
      onSuccess: () {
        Navigator.pop(context);
      },
      onError: (error) {
        ToastMessageHelper.showToastMessage(error);
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
    Navigator.pop(context);
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.black),
                title: Text(context.l10n.takePhoto),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: Colors.black),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }
}
