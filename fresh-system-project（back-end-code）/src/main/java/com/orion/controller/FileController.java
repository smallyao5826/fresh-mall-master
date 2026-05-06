package com.orion.controller;

import com.orion.pojo.User;
import com.orion.pojo.helper.Result;
import com.orion.service.UserService;
import com.orion.utils.JwtUtil;
import com.qcloud.cos.COSClient;
import com.qcloud.cos.model.ObjectMetadata;
import com.qcloud.cos.model.PutObjectRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/file")
@RequiredArgsConstructor
public class FileController {

    @Autowired
    private UserService userService;

    private final COSClient cosClient;

    @Value("${tencent.cos.bucket-name}")
    private String bucketName;

    // 通用文件上传
    @PostMapping("/upload")
    public Result<String> upload(@RequestParam("file") MultipartFile file) {
        try {
            String fileName = "/fresh/common/" + UUID.randomUUID() + "_" + file.getOriginalFilename();
            return uploadToCOS(file, fileName);
        } catch (Exception e) {
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }

    // 头像上传（需要认证）
    @PostMapping("/upload-avatar")
    public Result<Object> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            @RequestHeader("Authorization") String authHeader) {

        try {
            // Token验证
            if (!authHeader.startsWith("Bearer ")) {
                return Result.error("无效的Token格式");
            }
            String token = authHeader.substring(7).trim();
            Map<String, Object> claims = JwtUtil.parseToken(token);
            String userId = (String) claims.get("id");

            // 上传到COS
            String fileName = "avatar/" + UUID.randomUUID() + "_" + file.getOriginalFilename();
            Result<String> uploadResult = uploadToCOS(file, fileName);

            if (uploadResult.getCode() != 0) {
                return Result.error(uploadResult.getMessage());
            }

            // 更新用户头像并获取最新数据
            User updatedUser = userService.updateUserAvatar(userId, uploadResult.getData());

            return Result.success(updatedUser);

        } catch (Exception e) {
            return Result.error("操作失败: " + e.getMessage());
        }
    }

    // 通用COS上传方法
    private Result<String> uploadToCOS(MultipartFile file, String fileName) throws Exception {
        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());

        cosClient.putObject(
                new PutObjectRequest(bucketName, fileName, file.getInputStream(), metadata)
        );

        String url = "https://" + bucketName + ".cos.ap-guangzhou.myqcloud.com/" + fileName;
        return Result.success(url);
    }
}