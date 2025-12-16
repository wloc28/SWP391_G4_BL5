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
        <%@include file="../components/header.jsp" %>
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
                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="userId" value="${user.userId}">
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Username <span class="text-danger">*</span></label>
                                    <input type="text" name="username" class="form-control" 
                                           value="${user.username}" required>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" 
                                           value="${user.email}" disabled>
                                    <small class="text-muted">Email không thể thay đổi</small>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Họ tên <span class="text-danger">*</span></label>
                                    <input type="text" name="fullName" class="form-control" 
                                           value="${user.fullName}" required>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Số điện thoại</label>
                                    <input type="text" name="phoneNumber" class="form-control" 
                                           value="${user.phoneNumber}">
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Số dư <span class="text-danger">*</span></label>
                                    <input type="number" name="balance" class="form-control" 
                                           value="<fmt:formatNumber value="${user.balance}" type="number" maxFractionDigits="0" />" step="1" min="0" required>
                                    <small class="text-muted">Số dư sẽ được làm tròn (không có số thập phân)</small>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Vai trò <span class="text-danger">*</span></label>
                                    <select name="role" class="form-select" required>
                                        <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                        <option value="CUSTOMER" ${user.role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                    <select name="status" class="form-select" required>
                                        <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="BANNED" ${user.status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Ngày tạo</label>
                                    <input type="text" class="form-control" 
                                           value="<fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/>" disabled>
                                </div>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-save"></i> Lưu
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>

        <%@include file="../components/footer.jsp" %>
    </body>
</html>

