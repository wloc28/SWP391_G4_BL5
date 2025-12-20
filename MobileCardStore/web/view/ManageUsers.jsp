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

            /* Unified styles with ManageStorage */
            .search-form {
                background-color: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            .search-form .form-label {
                font-weight: 600;
                color: #495057;
                font-size: 0.9rem;
                margin-bottom: 8px;
            }
            .search-form .form-control,
            .search-form .form-select {
                border: 1px solid #ced4da;
                border-radius: 4px;
            }
            .search-form .form-control:focus,
            .search-form .form-select:focus {
                border-color: #0d6efd;
                box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.25);
            }

            .data-table {
                width: 100%;
                border-collapse: collapse;
            }
            .data-table thead { background-color: #f8f9fa; }
            .data-table th {
                padding: 12px;
                text-align: left;
                font-weight: 600;
                color: #212529;
                border-bottom: 2px solid #dee2e6;
                font-size: 0.9rem;
            }
            .data-table td {
                padding: 12px;
                border-bottom: 1px solid #e0e0e0;
                color: #495057;
                font-size: 0.95rem;
            }
            .data-table tbody tr:hover { background-color: #f8f9fa; }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-people"></i> Quản lý người dùng</span>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-primary btn-sm">
                        <i class="bi bi-speedometer2"></i> Về Dashboard
                    </a>
                </div>
                
                <div class="content-card-body">
            
            <!-- Filter Bar (Unified with ManageStorage) -->
            <div class="search-form mb-4">
                    <form method="get" action="${pageContext.request.contextPath}/admin/users" id="filterForm">
                        <!-- First Row: Keyword, Role, Status, Sort By -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-3">
                                <label class="form-label">Từ khóa</label>
                                <input type="text" class="form-control" name="keyword" id="keywordInput" value="${keyword}" 
                                       placeholder="Tên, email, sđt..." 
                                       maxlength="50">
                                <div class="invalid-feedback text-danger text-xs mt-1 hidden" id="keywordErrorMsg">Chỉ được nhập chữ cái, số, @, ., _, -, + và khoảng trắng (không quá 50 ký tự). Nếu chỉ nhập ký tự đặc biệt sẽ không có kết quả.</div>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Vai trò</label>
                                <select class="form-select" name="role">
                                    <option value="ALL" ${role == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                    <option value="CUSTOMER" ${role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Trạng thái</label>
                                <select class="form-select" name="status">
                                    <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                    <option value="BANNED" ${status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Sắp xếp</label>
                                <select class="form-select" name="sortBy">
                                    <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Ngày tạo</option>
                                    <option value="username" ${sortBy == 'username' ? 'selected' : ''}>Username</option>
                                    <option value="balance" ${sortBy == 'balance' ? 'selected' : ''}>Số dư</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Thứ tự</label>
                                <select class="form-select" name="sortDir">
                                    <option value="DESC" ${sortDir == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                    <option value="ASC" ${sortDir == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex align-items-end gap-2">
                                <button class="btn btn-primary" type="submit">Tìm kiếm</button>
                                <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/users">Reset</a>
                            </div>
                        </div>
                        <input type="hidden" name="page" value="1" id="pageInput">
                    </form>
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
                                <table class="data-table">
                                    <thead class="table-light">
                                        <tr>
                                            <th>ID</th>
                                            <th>User</th>
                                            <th>Email</th>
                                            <th>Số điện thoại</th>
                                            <th>Vai trò</th>
                                            <th>Trạng thái</th>
                                            <th>Số dư</th>
                                            <th>Ngày tạo</th>
                                            <th class="text-center">Hành động</th>
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
                                                <td>${u.phoneNumber}</td>
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
                                                <td class="text-center">
                                                    <div class="d-flex gap-1 justify-content-center">
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.userId}" class="btn btn-sm btn-primary">Chi tiết</a>
                                                        <a href="${pageContext.request.contextPath}/admin/user-edit?id=${u.userId}" class="btn btn-sm btn-warning">
                                                            <i class="bi bi-pencil"></i> Sửa
                                                        </a>
                                                        <form method="post" action="${pageContext.request.contextPath}/admin/users" id="statusForm_${u.userId}">
                                                            <input type="hidden" name="action" value="status">
                                                            <input type="hidden" name="userId" value="${u.userId}">
                                                            <c:choose>
                                                                <c:when test="${u.status == 'ACTIVE'}">
                                                                    <input type="hidden" name="status" value="BANNED">
                                                                    <button type="button" onclick="confirmStatusChange('${u.userId}', 'BANNED', '${u.username}', 'khoá')" class="btn btn-sm btn-danger">
                                                                        <i class="bi bi-lock"></i> Khoá
                                                                    </button>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <input type="hidden" name="status" value="ACTIVE">
                                                                    <button type="button" onclick="confirmStatusChange('${u.userId}', 'ACTIVE', '${u.username}', 'mở khoá')" class="btn btn-sm btn-success">
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
            // Form validation
            (function() {
                'use strict';
                window.addEventListener('load', function() {
                    var form = document.getElementById('filterForm');
                    var keywordInput = document.getElementById('keywordInput');
                    var invalidFeedback = document.getElementById('keywordErrorMsg');
                    
                    if (!keywordInput || !invalidFeedback) return;
                    
                    // Validation function for keyword
                    function validateKeyword(showErrors) {
                        var keywordValue = keywordInput.value.trim();
                        
                        // Reset validation state
                        keywordInput.classList.remove('border-danger', 'is-invalid');
                        invalidFeedback.classList.add('hidden');
                        invalidFeedback.textContent = '';
                        
                        // If empty, no validation needed
                        if (!keywordValue) {
                            return true;
                        }
                        
                        // Check if it's only spaces
                        if (keywordValue.replace(/\s+/g, '').length === 0) {
                            if (showErrors) {
                                keywordInput.classList.add('border-danger', 'is-invalid');
                                invalidFeedback.textContent = 'Vui lòng nhập ít nhất một ký tự (không chỉ khoảng trắng)';
                                invalidFeedback.classList.remove('hidden');
                            }
                            return false;
                        }
                        
                        // Check for invalid characters - allow: letters, numbers, @, ., _, -, +, and spaces
                        // Disallow: |, %, &, <, >, ', ", \, /, and other special chars that could cause issues
                        var invalidChars = /[^a-zA-Z0-9@.\s_\-+]/;
                        if (invalidChars.test(keywordValue)) {
                            if (showErrors) {
                                keywordInput.classList.add('border-danger', 'is-invalid');
                                invalidFeedback.textContent = 'Chỉ được nhập chữ cái, số, @, ., _, -, + và khoảng trắng';
                                invalidFeedback.classList.remove('hidden');
                            }
                            return false;
                        }
                        
                        // Check max length
                        if (keywordValue.length > 50) {
                            if (showErrors) {
                                keywordInput.classList.add('border-danger', 'is-invalid');
                                invalidFeedback.textContent = 'Từ khóa không được vượt quá 50 ký tự';
                                invalidFeedback.classList.remove('hidden');
                            }
                            return false;
                        }
                        
                        // Allow submission even if only special chars (will just return no results)
                        // No need to validate for at least one letter/number
                        return true;
                    }
                    
                    form.addEventListener('submit', function(event) {
                        if (!validateKeyword(true)) {
                            event.preventDefault();
                            event.stopPropagation();
                            keywordInput.focus();
                            return false;
                        }
                    }, false);
                    
                    // Clear error when user starts typing (no need for blur validation since we allow submission)
                    keywordInput.addEventListener('input', function() {
                        if (this.classList.contains('border-danger') || this.classList.contains('is-invalid')) {
                            this.classList.remove('border-danger', 'is-invalid');
                            invalidFeedback.classList.add('hidden');
                        }
                    });
                }, false);
            })();
            
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

