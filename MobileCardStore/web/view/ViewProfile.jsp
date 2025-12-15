<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Thông Tin Cá Nhân</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            /* Lớp CSS tùy chỉnh cho Nút Thay Đổi Avatar (Nền đỏ nhạt, Chữ trắng) */
            .btn-custom-light-red {
                /* Nền đỏ nhạt pastel (#ef9a9a là màu đỏ nhạt Material Design) */
                background-color: #ef9a9a; 
                
                /* Chữ trắng */
                color: #ffffff; 
                
                /* Viền cùng màu nền */
                border-color: #ef9a9a;
            }

            /* Hiệu ứng khi di chuột qua (Hover Effect) */
            .btn-custom-light-red:hover {
                /* Nền đậm hơn một chút khi hover */
                background-color: #e57373; 
                border-color: #e57373;
                color: #ffffff;
            }
        </style>
    </head>
    <body>
        
        <%@include file="../components/header_v2.jsp" %>

        <div class="container mt-5 mb-5">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <c:if test="${not empty requestScope.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>${requestScope.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="fas fa-exclamation-circle me-2"></i>${param.error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty requestScope.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i>${requestScope.success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="fas fa-check-circle me-2"></i>${param.success}
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </c:if>

                    <c:if test="${sessionScope.user == null}">
                        <div class="alert alert-warning">
                            <h5><i class="fas fa-exclamation-triangle me-2"></i>Bạn chưa đăng nhập!</h5>
                            <p class="mb-0">Vui lòng đăng nhập để xem thông tin cá nhân.</p>
                            <a href="${pageContext.request.contextPath}/view/login.jsp" class="btn btn-primary mt-3">Đăng nhập ngay</a>
                        </div>
                    </c:if>

                    <c:if test="${sessionScope.user != null}">
                        <c:set var="user" value="${sessionScope.user}"/>

                        <%
                            // Map avatar codes với URLs
                            java.util.Map<String, String> avatarMap = new java.util.HashMap<>();
                            avatarMap.put("image1", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-1.jpg");
                            avatarMap.put("image2", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-2.jpg");
                            avatarMap.put("image3", "https://linhkien283.com/wp-content/uploads/2025/10/Hinh-anh-avatar-vo-tri-cute-6.jpg");
                            
                            String defaultAvatar = avatarMap.get("image2");
                            String userImageCode = ((Models.User)session.getAttribute("user")).getImage();
                            String avatarUrl = defaultAvatar;
                            if (userImageCode != null && !userImageCode.trim().isEmpty()) {
                                avatarUrl = avatarMap.getOrDefault(userImageCode.trim(), defaultAvatar);
                            }
                            pageContext.setAttribute("avatarUrl", avatarUrl);
                            pageContext.setAttribute("avatarMap", avatarMap);
                            pageContext.setAttribute("currentImageCode", userImageCode != null ? userImageCode : "image2");
                        %>

                        <div class="card shadow-sm mb-4">
                            <div class="card-body bg-primary text-white rounded-top">
                                <div class="row align-items-center">
                                    <div class="col-md-3 text-center">
                                        <div class="mb-3"> 
                                            <img src="${avatarUrl}"
                                                alt="Avatar"
                                                class="rounded-circle border border-4 border-white shadow mb-2" 
                                                style="width: 120px; height: 120px; object-fit: cover;">

                                            <button type="button"
                                                    class="btn btn-sm mt-2 btn-custom-light-red" 
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#changeAvatarModal"
                                                    title="Thay đổi avatar">
                                                Thay đổi avatar
                                            </button>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <h2 class="mb-2">${user.fullName}</h2>
                                        <p class="mb-1"><i class="fas fa-envelope me-2"></i>${user.email}</p>
                                        <p class="mb-0">
                                            <span class="badge bg-light text-dark me-2">${user.role}</span>
                                            <span class="badge ${user.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">${user.status}</span>
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-4">
                                <div class="card shadow-sm h-100">
                                    <div class="card-header bg-light">
                                        <h5 class="mb-0"><i class="fas fa-user me-2"></i>Thông Tin Cá Nhân</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="mb-3 pb-3 border-bottom">
                                            <label class="form-label text-muted small mb-1">Username</label>
                                            <p class="mb-0 fw-bold fs-5">${user.username}</p>
                                        </div>

                                        <div class="mb-3 pb-3 border-bottom">
                                            <label class="form-label text-muted small mb-1">Họ và Tên</label>
                                            <p class="mb-0 fw-bold fs-5">${user.fullName}</p>
                                        </div>

                                        <div class="mb-3 pb-3 border-bottom">
                                            <label class="form-label text-muted small mb-1">Số Điện Thoại</label>
                                            <p class="mb-0 fw-bold fs-5">
                                                <i class="fas fa-phone me-2 text-primary"></i>${user.phoneNumber}
                                            </p>
                                        </div>

                                        <div class="mb-0">
                                            <label class="form-label text-muted small mb-1">Email</label>
                                            <p class="mb-0 fw-bold fs-5">
                                                <i class="fas fa-envelope me-2 text-primary"></i>${user.email}
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6 mb-4">
                                <div class="card shadow-sm h-100">
                                    <div class="card-header bg-light">
                                        <h5 class="mb-0"><i class="fas fa-wallet me-2"></i>Thông Tin Tài Khoản</h5>
                                    </div>
                                    <div class="card-body">
                                        <div class="mb-3 pb-3 border-bottom">
                                            <label class="form-label text-muted small mb-1">Số Dư</label>
                                            <p class="mb-0 fw-bold fs-4 text-success">
                                                <i class="fas fa-coins me-2"></i>${user.balance} VNĐ
                                            </p>
                                        </div>

                                        <div class="mb-3 pb-3 border-bottom">
                                            <label class="form-label text-muted small mb-1">Trạng Thái</label>
                                            <p class="mb-0">
                                                <span class="badge ${user.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'} fs-6">
                                                    ${user.status}
                                                </span>
                                            </p>
                                        </div>

                                        <div class="mb-0">
                                            <label class="form-label text-muted small mb-1">Ngày Tạo Tài Khoản</label>
                                            <p class="mb-0">
                                                <i class="fas fa-calendar me-2 text-primary"></i>
                                                <fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="card shadow-sm">
                            <div class="card-body">
                                <div class="d-flex flex-wrap gap-3 justify-content-center">
                                    <button type="button" class="btn btn-primary btn-lg" data-bs-toggle="modal" data-bs-target="#updateProfileModal">
                                        <i class="fas fa-edit me-2"></i>Sửa Thông Tin
                                    </button>
                                    <button type="button" class="btn btn-warning btn-lg" data-bs-toggle="modal" data-bs-target="#changePasswordModal">
                                        <i class="fas fa-key me-2"></i>Đổi Mật Khẩu
                                    </button>
                                    <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary btn-lg">
                                        <i class="fas fa-arrow-left me-2"></i>Quay Lại
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <%@include file="UpdateProfile.jsp" %>

        <%@include file="ChangePassword.jsp" %>

        <!-- Change Avatar Modal -->
        <div class="modal fade" id="changeAvatarModal" tabindex="-1" aria-labelledby="changeAvatarModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content">
                    <div class="modal-header bg-primary text-white">
                        <h5 class="modal-title" id="changeAvatarModalLabel">
                            <i class="fas fa-image me-2"></i>Chọn Avatar
                        </h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form action="updateProfile" method="post" id="changeAvatarForm">
                            <input type="hidden" name="username" value="${user.username}">
                            <input type="hidden" name="fullname" value="${user.fullName}">
                            <input type="hidden" name="phone" value="${user.phoneNumber}">
                            <input type="hidden" name="imageCode" id="selectedImageCode" value="${currentImageCode}">
                            
                            <p class="text-muted mb-4 text-center">Chọn một avatar từ các hình ảnh dưới đây:</p>
                            
                            <div class="row g-4 justify-content-center">
                                <c:forEach var="entry" items="${avatarMap}">
                                    <div class="col-4 text-center">
                                        <div class="avatar-option position-relative ${entry.key == currentImageCode ? 'selected' : ''}" 
                                             data-image-code="${entry.key}"
                                             style="cursor: pointer; padding: 15px; border: 3px solid ${entry.key == currentImageCode ? '#007bff' : '#dee2e6'}; border-radius: 15px; transition: all 0.3s; background-color: ${entry.key == currentImageCode ? '#f0f8ff' : '#ffffff'};">
                                            <img src="${entry.value}" 
                                                 alt="Avatar ${entry.key}" 
                                                 class="img-fluid rounded-circle mb-2"
                                                 style="width: 120px; height: 120px; object-fit: cover; border: 2px solid #dee2e6;">
                                            <c:if test="${entry.key == currentImageCode}">
                                                <div class="position-absolute top-0 end-0 bg-primary text-white rounded-circle shadow" 
                                                     style="width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; margin: 5px;">
                                                    <i class="fas fa-check"></i>
                                                </div>
                                            </c:if>
                                            <div class="mt-2">
                                                <small class="text-muted">${entry.key}</small>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                            <i class="fas fa-times me-2"></i>Hủy
                        </button>
                        <button type="submit" form="changeAvatarForm" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>Lưu Thay Đổi
                        </button>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            // Xử lý chọn avatar
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('.avatar-option').forEach(function(option) {
                    option.addEventListener('click', function() {
                        // Bỏ chọn tất cả
                        document.querySelectorAll('.avatar-option').forEach(function(opt) {
                            opt.style.borderColor = '#dee2e6';
                            opt.style.backgroundColor = '#ffffff';
                            const checkIcon = opt.querySelector('.position-absolute.bg-primary');
                            if (checkIcon) {
                                checkIcon.remove();
                            }
                        });
                        
                        // Chọn option hiện tại
                        this.style.borderColor = '#007bff';
                        this.style.backgroundColor = '#f0f8ff';
                        const imageCode = this.getAttribute('data-image-code');
                        document.getElementById('selectedImageCode').value = imageCode;
                        
                        // Thêm icon check nếu chưa có
                        if (!this.querySelector('.position-absolute.bg-primary')) {
                            const checkIcon = document.createElement('div');
                            checkIcon.className = 'position-absolute top-0 end-0 bg-primary text-white rounded-circle shadow';
                            checkIcon.style.cssText = 'width: 35px; height: 35px; display: flex; align-items: center; justify-content: center; margin: 5px;';
                            checkIcon.innerHTML = '<i class="fas fa-check"></i>';
                            this.appendChild(checkIcon);
                        }
                    });
                });
            });
        </script>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>

