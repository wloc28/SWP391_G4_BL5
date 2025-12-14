<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Map avatar codes với URLs
    java.util.Map<String, String> avatarMap = new java.util.HashMap<>();
    avatarMap.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");
    avatarMap.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");
    avatarMap.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");
    
    String defaultAvatar = avatarMap.get("image2");
    
    // Set vào request scope
    request.setAttribute("avatarMap", avatarMap);
    request.setAttribute("defaultAvatar", defaultAvatar);
    
    // Helper function để lấy avatar URL
    String getAvatarUrl(String imageCode) {
        if (imageCode == null || imageCode.trim().isEmpty()) {
            return defaultAvatar;
        }
        return avatarMap.getOrDefault(imageCode.trim(), defaultAvatar);
    }
%>

