package util;

import java.util.HashMap;
import java.util.Map;

/**
 * Utility class để quản lý avatar mapping
 * Map mã số (image1, image2, image3) với URL
 */
public class AvatarUtil {
    
  
    private static final Map<String, String> AVATAR_MAP = new HashMap<>();
    
    // Avatar mặc định
    public static final String DEFAULT_AVATAR_CODE = "image1";
    
    static {
        AVATAR_MAP.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");
        AVATAR_MAP.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");
        AVATAR_MAP.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");
    }
    
    /**
     * Lấy URL avatar từ mã số
     * @param imageCode Mã số avatar (image1, image2, image3)
     * @return URL avatar, nếu không tìm thấy trả về avatar mặc định
     */
    public static String getAvatarUrl(String imageCode) {
        if (imageCode == null || imageCode.trim().isEmpty()) {
            return AVATAR_MAP.get(DEFAULT_AVATAR_CODE);
        }
        return AVATAR_MAP.getOrDefault(imageCode.trim(), AVATAR_MAP.get(DEFAULT_AVATAR_CODE));
    }
    
    /**
     * Lấy URL avatar mặc định
     * @return URL avatar mặc định
     */
    public static String getDefaultAvatarUrl() {
        return AVATAR_MAP.get(DEFAULT_AVATAR_CODE);
    }
    
    /**
     * Kiểm tra mã số avatar có hợp lệ không
     * @param imageCode Mã số avatar
     * @return true nếu hợp lệ, false nếu không
     */
    public static boolean isValidAvatarCode(String imageCode) {
        return imageCode != null && AVATAR_MAP.containsKey(imageCode.trim());
    }
    
    /**
     * Lấy tất cả các avatar codes
     * @return Mảng các mã số avatar
     */
    public static String[] getAllAvatarCodes() {
        return AVATAR_MAP.keySet().toArray(new String[0]);
    }
    
    /**
     * Lấy tất cả các avatar URLs
     * @return Mảng các URL avatar
     */
    public static String[] getAllAvatarUrls() {
        return AVATAR_MAP.values().toArray(new String[0]);
    }
    
    /**
     * Lấy Map chứa tất cả avatar codes và URLs
     * @return Map<String, String> với key là mã số, value là URL
     */
    public static Map<String, String> getAllAvatars() {
        return new HashMap<>(AVATAR_MAP);
    }
}

