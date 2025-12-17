<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý người dùng</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                background-color: #f8f9fa;
            }
            
            .content-card {
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                margin-bottom: 20px;
            }
            
            .content-card-header {
                padding: 20px;
                border-bottom: 1px solid #e0e0e0;
                font-weight: 600;
                color: #212529;
                font-size: 1.1rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .content-card-body {
                padding: 20px;
            }
            
            .badge-role { background: #e0f2fe; color: #0b4f8a; }
            .badge-status-active { background: #d1fae5; color: #065f46; }
            .badge-status-banned { background: #fee2e2; color: #991b1b; }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-people"></i> Quản lý người dùng</span>
                </div>
                
                <div class="content-card-body">
            
            <!-- Filter Bar (Horizontal) -->
            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
                        <!-- First Row: Keyword, Role, Status, Sort By -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-3">
                                <label class="form-label small">Từ khóa</label>
                                <input type="text" class="form-control form-control-sm" name="keyword" value="${keyword}" placeholder="Tên, email, sđt...">
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small">Vai trò</label>
                                <select class="form-select form-select-sm" name="role">
                                    <option value="ALL" ${role == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                    <option value="CUSTOMER" ${role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small">Trạng thái</label>
                                <select class="form-select form-select-sm" name="status">
                                    <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                    <option value="BANNED" ${status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small">Sắp xếp</label>
                                <select class="form-select form-select-sm" name="sortBy">
                                    <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Ngày tạo</option>
                                    <option value="username" ${sortBy == 'username' ? 'selected' : ''}>Username</option>
                                    <option value="balance" ${sortBy == 'balance' ? 'selected' : ''}>Số dư</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small">Thứ tự</label>
                                <select class="form-select form-select-sm" name="sortDir">
                                    <option value="DESC" ${sortDir == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                    <option value="ASC" ${sortDir == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                </select>
                            </div>
                            <div class="col-md-1 d-flex align-items-end">
                                <div class="w-100">
                                    <button class="btn btn-dark btn-sm w-100" type="submit">Tìm</button>
                                </div>
                            </div>
                        </div>
                        <!-- Second Row: Reset Button -->
                        <div class="row">
                            <div class="col-12">
                                <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/admin/users">Reset</a>
                            </div>
                        </div>
                        <input type="hidden" name="page" value="1" id="pageInput">
                    </form>
                </div>
            </div>

            <!-- Content -->
            <div class="w-100">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <div class="text-muted small">Hiển thị ${users != null ? users.size() : 0} / ${totalCount} người dùng</div>
                        <c:if test="${not empty param.error}">
                            <div class="alert alert-danger mb-0 py-1 px-2 small">${param.error}</div>
                        </c:if>
                    </div>

                    <c:choose>
                        <c:when test="${empty users}">
                            <div class="alert alert-info">Không có người dùng phù hợp.</div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>User</th>
                                            <th>Email</th>
                                            <th>Vai trò</th>
                                            <th>Trạng thái</th>
                                            <th>Số dư</th>
                                            <th>Ngày tạo</th>
                                            <th class="text-center">Trạng thái</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="u" items="${users}">
                                            <tr>
                                                <td>${u.userId}</td>
                                                <td>
                                                    <div class="fw-semibold">${u.username}</div>
                                                    <div class="text-muted small">${u.fullName}</div>
                                                </td>
                                                <td>${u.email}</td>
                                                <td><span class="badge badge-role">${u.role}</span></td>
                                                <td class="text-center">
                                                    <c:choose>
                                                        <c:when test="${u.status == 'ACTIVE'}">
                                                            <span class="badge badge-status-active">ACTIVE</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge-status-banned">BANNED</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><fmt:formatNumber value="${u.balance}" type="number" maxFractionDigits="0" /> đ</td>
                                                <td><fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy"/></td>
                                                <td>
                                                    <div class="d-flex gap-1">
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.userId}" class="btn btn-sm btn-outline-primary">Chi tiết</a>
                                                        <a href="${pageContext.request.contextPath}/admin/user-edit?id=${u.userId}" class="btn btn-sm btn-outline-warning">
                                                            <i class="bi bi-pencil"></i> Sửa
                                                        </a>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" id="statusForm_${u.userId}">
                                                            <input type="hidden" name="action" value="status">
                                                            <input type="hidden" name="userId" value="${u.userId}">
                                                            <c:choose>
                                                                <c:when test="${u.status == 'ACTIVE'}">
                                                                    <input type="hidden" name="status" value="BANNED">
                                                                    <button type="button" onclick="confirmStatusChange('${u.userId}', 'BANNED', '${u.username}', 'khoá')" class="btn btn-sm btn-outline-danger">
                                                                        <i class="bi bi-lock"></i> Khoá
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <input type="hidden" name="status" value="ACTIVE">
                                                                    <button type="button" onclick="confirmStatusChange('${u.userId}', 'ACTIVE', '${u.username}', 'mở khoá')" class="btn btn-sm btn-outline-success">
                                                                        <i class="bi bi-unlock"></i> Mở
                                                                    </button>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </form>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <nav>
                                    <ul class="pagination justify-content-center">
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage - 1})">Trước</a>
                                        </li>
                                        <c:forEach var="i" begin="1" end="${totalPages}">
                                            <c:if test="${i <= 3 || i > totalPages - 3 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                                <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                    <a class="page-link" href="javascript:void(0)" onclick="goToPage(${i})">${i}</a>
                                                </li>
                                            </c:if>
                                        </c:forEach>
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <a class="page-link" href="javascript:void(0)" onclick="goToPage(${currentPage + 1})">Sau</a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <%@include file="../components/footer.jsp" %>

        <c:set var="totalPagesValue" value="${totalPages != null ? totalPages : 1}" />
        <script>
            function goToPage(page) {
                var totalPages = ${totalPagesValue};
                if (page < 1 || page > totalPages) return;
                document.getElementById('pageInput').value = page;
                document.getElementById('filterForm').submit();
            }
            
            function confirmStatusChange(userId, newStatus, username, action) {
                Swal.fire({
                    title: 'Xác nhận',
                    text: 'Bạn có chắc chắn muốn ' + action + ' tài khoản "' + username + '" không?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: newStatus === 'BANNED' ? '#d33' : '#28a745',
                    cancelButtonColor: '#6c757d',
                    confirmButtonText: 'Xác nhận',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        document.getElementById('statusForm_' + userId).submit();
                    }
                });
            }
        </script>
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

