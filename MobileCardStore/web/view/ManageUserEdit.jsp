<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chỉnh sửa người dùng</title>
        <%@include file="../components/libs.jsp" %>
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
                                    <input type="text" class="form-control" name="username" value="${user.username}" 
                                           required minlength="3" maxlength="50" pattern="[a-zA-Z0-9_]+">
                                    <div class="invalid-feedback">Tên đăng nhập phải có 3-50 ký tự, chỉ gồm chữ, số và dấu gạch dưới</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" name="email" value="${user.email}" required>
                                    <div class="invalid-feedback">Vui lòng nhập địa chỉ email hợp lệ</div>
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
                                    <label class="form-label">Số dư</label>
                                    <input type="number" step="1" class="form-control" name="balance" 
                                           value="${user.balance}" min="0"
                                           ${(sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId) ? '' : 'disabled'}
                                           placeholder="${(sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId) ? 'Nhập số dư' : 'Số dư không thể chỉnh sửa'}">
                                    <c:choose>
                                        <c:when test="${sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId}">
                                            <small class="text-muted">Bạn có thể chỉnh sửa số dư của chính mình</small>
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-muted">Số dư chỉ có thể thay đổi thông qua giao dịch</small>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="invalid-feedback">Số dư không được âm</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Mật khẩu mới (để trống nếu không đổi)</label>
                                    <input type="password" class="form-control" name="newPassword" 
                                           placeholder="Nhập mật khẩu mới..." minlength="6" maxlength="100">
                                    <div class="invalid-feedback">Mật khẩu phải có ít nhất 6 ký tự</div>
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
        (function() {
            'use strict';
            window.addEventListener('load', function() {
                var forms = document.getElementsByTagName('form');
                var validation = Array.prototype.filter.call(forms, function(form) {
                    form.addEventListener('submit', function(event) {
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                });
            }, false);
        })();
        </script>
    </body>
</html>

