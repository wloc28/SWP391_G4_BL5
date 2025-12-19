<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chỉnh sửa người dùng</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .form-control:read-only {
                background-color: #e9ecef;
                cursor: not-allowed;
            }
            
            .is-valid {
                border-color: #198754;
            }
            
            .is-invalid {
                border-color: #dc3545;
            }
            
            #passwordMatchError {
                display: none;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container py-4">
            <h2 class="mb-3">Chỉnh sửa người dùng</h2>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-circle me-2"></i>
                    <c:choose>
                        <c:when test="${param.error == 'update_failed'}">Cập nhật người dùng thất bại!</c:when>
                        <c:when test="${param.error == 'invalid_id'}">ID không hợp lệ!</c:when>
                        <c:when test="${param.error == 'user_not_found'}">Không tìm thấy người dùng!</c:when>
                        <c:otherwise>${param.error}</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty param.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle me-2"></i>
                    <c:choose>
                        <c:when test="${param.success == 'update_success'}">Cập nhật người dùng thành công!</c:when>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty user}">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/user-edit" novalidate>
                            <input type="hidden" name="userId" value="${user.userId}">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Tên đăng nhập</label>
                                    <input type="text" class="form-control" value="${user.username}" 
                                           readonly style="background-color: #e9ecef; cursor: not-allowed;">
                                    <input type="hidden" name="username" value="${user.username}">
                                    <small class="text-muted">Tên đăng nhập không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" value="${user.email}" 
                                           readonly style="background-color: #e9ecef; cursor: not-allowed;">
                                    <input type="hidden" name="email" value="${user.email}">
                                    <small class="text-muted">Email không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Họ tên</label>
                                    <input type="text" class="form-control" name="fullName" value="${user.fullName}" maxlength="100">
                                    <div class="invalid-feedback">Họ tên không được vượt quá 100 ký tự</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số điện thoại</label>
                                    <input type="tel" class="form-control" name="phoneNumber" value="${user.phoneNumber}" 
                                           pattern="[0-9]{10,15}" maxlength="15">
                                    <div class="invalid-feedback">Số điện thoại phải có 10-15 chữ số</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Vai trò</label>
                                    <select class="form-select" name="role" required>
                                        <option value="CUSTOMER" ${user.role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                        <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                    </select>
                                    <div class="invalid-feedback">Vui lòng chọn vai trò</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái</label>
                                    <select class="form-select" name="status" required>
                                        <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="BANNED" ${user.status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                    </select>
                                    <div class="invalid-feedback">Vui lòng chọn trạng thái</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Mật khẩu mới (để trống nếu không đổi)</label>
                                    <input type="password" class="form-control" name="newPassword" id="newPassword"
                                           placeholder="Nhập mật khẩu mới..." minlength="6" maxlength="100">
                                    <div class="invalid-feedback">Mật khẩu phải có ít nhất 6 ký tự</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Nhập lại mật khẩu mới</label>
                                    <input type="password" class="form-control" name="confirmPassword" id="confirmPassword"
                                           placeholder="Nhập lại mật khẩu mới..." minlength="6" maxlength="100">
                                    <div class="invalid-feedback" id="passwordMatchError">Mật khẩu nhập lại không khớp</div>
                                    <small class="text-muted">Chỉ cần nhập khi thay đổi mật khẩu</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số dư</label>

                                    <!-- Input hiển thị (format VND) -->
                                    <input type="text"
                                           class="form-control"
                                           id="balanceDisplay"
                                           value="<fmt:formatNumber value='${user.balance}' type='number' groupingUsed='true'/>"
                                           ${(sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId) ? '' : 'readonly'}
                                           placeholder="0 ₫">

                                    <!-- Input thật gửi về server -->
                                    <input type="hidden"
                                           name="balance"
                                           id="balance"
                                           value="${user.balance}">

                                    <c:choose>
                                        <c:when test="${sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId}">
                                            <small class="text-muted">Bạn có thể chỉnh sửa số dư của chính mình (VND)</small>
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-muted">Số dư chỉ có thể thay đổi thông qua giao dịch</small>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                            </div>

                            <hr class="my-4">

                            <div class="d-flex gap-3 flex-wrap">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg"></i> Lưu thay đổi
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>

        <%@include file="../components/footer.jsp" %>

        <!-- Form validation script -->
        <script>
            (function () {
                'use strict';
                window.addEventListener('load', function () {
                    var forms = document.getElementsByTagName('form');
                    var form = forms[0];
                    if (!form) return;
                    
                    var newPasswordInput = document.getElementById('newPassword');
                    var confirmPasswordInput = document.getElementById('confirmPassword');
                    var passwordMatchError = document.getElementById('passwordMatchError');
                    var formValidated = false;
                        
                    // Password match validation - only show errors after form submission
                    function validatePasswordMatch(showErrors) {
                        if (!newPasswordInput || !confirmPasswordInput) return true;
                        
                        var newPassword = newPasswordInput.value.trim();
                        var confirmPassword = confirmPasswordInput.value.trim();
                        
                        // Reset validation state
                        confirmPasswordInput.classList.remove('is-invalid', 'is-valid');
                        if (passwordMatchError) passwordMatchError.style.display = 'none';
                        
                        // If new password is provided, confirm password must match
                        if (newPassword.length > 0) {
                            if (confirmPassword.length === 0) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Vui lòng nhập lại mật khẩu mới';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            } else if (newPassword !== confirmPassword) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Mật khẩu nhập lại không khớp';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            } else {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-valid');
                                }
                                return true;
                            }
                        } else {
                            // If new password is empty, confirm password should also be empty
                            if (confirmPassword.length > 0) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Vui lòng nhập mật khẩu mới trước';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            }
                            return true;
                        }
                    }
                    
                    // Real-time validation - only show visual feedback after form has been submitted
                    if (newPasswordInput && confirmPasswordInput) {
                        newPasswordInput.addEventListener('input', function() {
                            if (formValidated) {
                                validatePasswordMatch(true);
                            }
                        });
                        
                        confirmPasswordInput.addEventListener('input', function() {
                            if (formValidated) {
                                validatePasswordMatch(true);
                            }
                        });
                    }
                    
                    form.addEventListener('submit', function (event) {
                        formValidated = true;
                        
                        // Validate password match before form validation
                        if (!validatePasswordMatch(true)) {
                            event.preventDefault();
                            event.stopPropagation();
                            form.classList.add('was-validated');
                            return false;
                        }
                        
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                }, false);
            })();
        </script>
    </body>
</html>

