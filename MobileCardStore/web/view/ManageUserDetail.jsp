<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chi tiết người dùng</title>
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        <div class="container py-4">
            <h2 class="mb-3">Chi tiết người dùng</h2>

            <c:if test="${not empty error}">
                <div class="alert alert-danger">${error}</div>
            </c:if>

            <c:if test="${not empty user}">
                <div class="row">
                    <div class="col-md-8">
                        <div class="card shadow-sm mb-3">
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <h5 class="card-title mb-1">${user.username}</h5>
                                        <div class="text-muted small">${user.email}</div>
                                    </div>
                                    <div>
                                        <span class="badge bg-secondary me-2">${user.role}</span>
                                        <c:choose>
                                            <c:when test="${user.status == 'ACTIVE'}">
                                                <span class="badge bg-success">ACTIVE</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger">BANNED</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <hr>
                                <div class="row g-3">
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Họ tên</div>
                                        <div class="fw-semibold">${user.fullName}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Số điện thoại</div>
                                        <div class="fw-semibold">${user.phoneNumber}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Số dư</div>
                                        <div class="fw-semibold">${user.balance}</div>
                                    </div>
                                    <div class="col-sm-6">
                                        <div class="text-muted small">Ngày tạo</div>
                                        <div class="fw-semibold"><fmt:formatDate value="${user.createdAt}" pattern="dd/MM/yyyy HH:mm"/></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-4">
                        <div class="card shadow-sm mb-3">
                            <div class="card-body">
                                <h6 class="card-title">Hành động</h6>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                    <input type="hidden" name="action" value="status">
                                    <input type="hidden" name="userId" value="${user.userId}">
                                    <input type="hidden" name="redirect" value="detail">
                                    <c:choose>
                                        <c:when test="${user.status == 'ACTIVE'}">
                                            <input type="hidden" name="status" value="BANNED">
                                            <button type="submit" class="btn btn-danger w-100 mb-2">Khoá tài khoản</button>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="hidden" name="status" value="ACTIVE">
                                            <button type="submit" class="btn btn-success w-100 mb-2">Mở khoá tài khoản</button>
                                        </c:otherwise>
                                    </c:choose>
                                </form>
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary w-100">Quay lại danh sách</a>
                            </div>
                        </div>

                        <div class="card shadow-sm">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <h6 class="card-title mb-0">Cập nhật thông tin</h6>
                                    <span class="text-muted small">Lưu ý: không đổi mật khẩu tại đây</span>
                                </div>
                                <hr>
                                <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                    <input type="hidden" name="action" value="update">
                                    <input type="hidden" name="userId" value="${user.userId}">
                                    <div class="mb-2">
                                        <label class="form-label small">Username</label>
                                        <input type="text" name="username" class="form-control form-control-sm" value="${user.username}">
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label small">Họ tên</label>
                                        <input type="text" name="fullName" class="form-control form-control-sm" value="${user.fullName}">
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label small">Số điện thoại</label>
                                        <input type="text" name="phoneNumber" class="form-control form-control-sm" value="${user.phoneNumber}">
                                    </div>
                                    <div class="mb-2">
                                        <label class="form-label small">Số dư</label>
                                        <input type="number" step="0.01" name="balance" class="form-control form-control-sm" value="${user.balance}">
                                    </div>
                                    <div class="row g-2 mb-2">
                                        <div class="col-6">
                                            <label class="form-label small">Vai trò</label>
                                            <select name="role" class="form-select form-select-sm">
                                                <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                                <option value="CUSTOMER" ${user.role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                            </select>
                                        </div>
                                        <div class="col-6">
                                            <label class="form-label small">Trạng thái</label>
                                            <select name="status" class="form-select form-select-sm">
                                                <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                                <option value="BANNED" ${user.status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary btn-sm">Lưu thay đổi</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </div>

        <%@include file="../components/footer.jsp" %>
        <c:if test="${param.selfBan == 'true'}">
            <script>
                Swal.fire({
                    icon: 'warning',
                    title: 'Không thể khoá tài khoản của chính bạn',
                    confirmButtonText: 'OK'
                });
            </script>
        </c:if>
    </body>
</html>

