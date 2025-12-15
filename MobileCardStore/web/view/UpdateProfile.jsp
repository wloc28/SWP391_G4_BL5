<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!-- Update Profile Modal -->

<div class="modal fade" id="updateProfileModal" tabindex="-1" aria-labelledby="updateProfileModalLabel" aria-hidden="true">

    <div class="modal-dialog modal-dialog-centered">

        <div class="modal-content">

            <div class="modal-header bg-primary text-white">

                <h5 class="modal-title" id="updateProfileModalLabel">Sửa Thông Tin</h5>

                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>

            </div>

            <div class="modal-body">

                <form action="updateProfile" method="post" id="updateProfileForm">

                    <c:set var="user" value="${sessionScope.user}"/>

                    

                    <%

                        // Map avatar codes với URLs

                        java.util.Map<String, String> avatarMap = new java.util.HashMap<>();

                        avatarMap.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");

                        avatarMap.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");

                        avatarMap.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");

                        String userImageCode = ((Models.User)session.getAttribute("user")).getImage();

                        String currentImageCode = userImageCode != null && !userImageCode.trim().isEmpty() ? userImageCode : "image2";

                        pageContext.setAttribute("currentImageCode", currentImageCode);

                        pageContext.setAttribute("avatarMap", avatarMap);

                    %>

                    

                    <input type="hidden" name="imageCode" id="updateImageCode" value="${currentImageCode}">

                    

                    <div class="mb-3">

                        <label for="update_username" class="form-label fw-bold">

                            <i class="fas fa-user me-2"></i>Username <span class="text-danger">*</span>

                        </label>

                        <input type="text" 

                               name="username" 

                               class="form-control form-control-lg" 

                               id="update_username" 

                               value="${user.username}" 

                               placeholder="Nhập username"

                               required>

                    </div>

                    

                    <div class="mb-3">

                        <label for="update_fullname" class="form-label fw-bold">

                            <i class="fas fa-id-card me-2"></i>Họ và Tên <span class="text-danger">*</span>

                        </label>

                        <input type="text" 

                               name="fullname" 

                               class="form-control form-control-lg" 

                               id="update_fullname" 

                               value="${user.fullName}" 

                               placeholder="Nhập họ và tên"

                               pattern="[^\d]+"

                               title="Họ tên không được chứa số"

                               required>

                        <div class="form-text">Họ tên không được chứa số</div>

                    </div>

                    

                    <div class="mb-3">

                        <label for="update_phone" class="form-label fw-bold">

                            <i class="fas fa-phone me-2"></i>Số Điện Thoại <span class="text-danger">*</span>

                        </label>

                        <input type="tel" 

                               name="phone" 

                               class="form-control form-control-lg" 

                               id="update_phone" 

                               value="${user.phoneNumber}" 

                               placeholder="Nhập số điện thoại"

                               pattern="[0-9]*"

                               title="Chỉ nhập số"

                               required>

                        <div class="form-text">Chỉ nhập số, không có ký tự đặc biệt</div>

                    </div>

                    

                    <div class="mb-3">

                        <label class="form-label fw-bold">

                            <i class="fas fa-envelope me-2"></i>Email

                        </label>

                        <input type="email" 

                               class="form-control form-control-lg bg-light" 

                               value="${user.email}" 

                               readonly

                               disabled>

                        <div class="form-text"><i class="fas fa-info-circle me-1"></i>Email không thể thay đổi</div>

                    </div>

                </form>

            </div>

            <div class="modal-footer">

                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">

                    <i class="fas fa-times me-2"></i>Hủy

                </button>

                <button type="submit" form="updateProfileForm" class="btn btn-primary">

                    <i class="fas fa-save me-2"></i>Lưu Thay Đổi

                </button>

            </div>

        </div>

    </div>

</div>
