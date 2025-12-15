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
            .badge-role { background: #e0f2fe; color: #0b4f8a; }
            .badge-status-active { background: #d1fae5; color: #065f46; }
            .badge-status-banned { background: #fee2e2; color: #991b1b; }
        </style>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        <div class="container py-4">
            <h2 class="mb-3">Quản lý người dùng</h2>
            <div class="row">
                <!-- Sidebar filter -->
                <div class="col-lg-3 mb-3">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <h6 class="card-title">Bộ lọc</h6>
                            <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
                                <div class="mb-3">
                                    <label class="form-label">Từ khóa</label>
                                    <input type="text" class="form-control" name="keyword" value="${keyword}" placeholder="Tên, email, sđt...">
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Vai trò</label>
                                    <select class="form-select" name="role">
                                        <option value="ALL" ${role == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                        <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                        <option value="CUSTOMER" ${role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select class="form-select" name="status">
                                        <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                        <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="BANNED" ${status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                    </select>
                                </div>
                                <div class="row g-2 mb-3">
                                    <div class="col-6">
                                        <label class="form-label">Sắp xếp</label>
                                        <select class="form-select" name="sortBy">
                                            <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Ngày tạo</option>
                                            <option value="username" ${sortBy == 'username' ? 'selected' : ''}>Username</option>
                                            <option value="balance" ${sortBy == 'balance' ? 'selected' : ''}>Số dư</option>
                                        </select>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label">Thứ tự</label>
                                        <select class="form-select" name="sortDir">
                                            <option value="DESC" ${sortDir == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                            <option value="ASC" ${sortDir == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                        </select>
                                    </div>
                                </div>
                                <input type="hidden" name="page" value="1" id="pageInput">
                                <div class="d-grid gap-2">
                                    <button class="btn btn-dark" type="submit">Tìm kiếm</button>
                                    <a class="btn btn-outline-secondary" href="admin/users">Reset</a>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Content -->
                <div class="col-lg-9">
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
                                                <td>${u.balance}</td>
                                                <td><fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy"/></td>
                                                <td>
                                                    <div class="d-flex gap-1">
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.userId}" class="btn btn-sm btn-outline-primary">Chi tiết</a>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/users">
                                                            <input type="hidden" name="action" value="status">
                                                            <input type="hidden" name="userId" value="${u.userId}">
                                                            <c:choose>
                                                                <c:when test="${u.status == 'ACTIVE'}">
                                                                    <input type="hidden" name="status" value="BANNED">
                                                                    <button type="submit" class="btn btn-sm btn-outline-danger">Khoá</button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <input type="hidden" name="status" value="ACTIVE">
                                                                    <button type="submit" class="btn btn-sm btn-outline-success">Mở</button>
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

        <script>
            function goToPage(page) {
                const totalPages = ${totalPages != null ? totalPages : 1};
                if (page < 1 || page > totalPages) return;
                document.getElementById('pageInput').value = page;
                document.getElementById('filterForm').submit();
            }
        </script>
    </body>
</html>

