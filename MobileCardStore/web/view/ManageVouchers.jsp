<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý Voucher</title>
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
            
            .data-table {
                width: 100%;
                border-collapse: collapse;
            }
            
            .data-table thead {
                background-color: #f8f9fa;
            }
            
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
            
            .data-table tbody tr:hover {
                background-color: #f8f9fa;
            }
            
            .status-badge {
                padding: 5px 12px;
                border-radius: 20px;
                font-size: 0.85rem;
                font-weight: 500;
                display: inline-block;
            }
            
            .status-active {
                background-color: #d1e7dd;
                color: #0f5132;
            }
            
            .status-inactive {
                background-color: #f8d7da;
                color: #842029;
            }
            
            .btn-action {
                padding: 5px 10px;
                margin: 0 2px;
                font-size: 0.85rem;
            }
            
            .expired-badge {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .expiring-soon {
                background-color: #ffeaa7;
                color: #d63031;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-ticket-perforated"></i> Quản lý Voucher</span>
                    <a href="${pageContext.request.contextPath}/vlist?action=add" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Thêm voucher mới
                    </a>
                </div>
                
                <div class="content-card-body">
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.error == 'add_failed'}">Thêm voucher thất bại!</c:when>
                                <c:when test="${param.error == 'update_failed'}">Cập nhật voucher thất bại!</c:when>
                                <c:when test="${param.error == 'delete_failed'}">Xóa voucher thất bại!</c:when>
                                <c:when test="${param.error == 'invalid_id'}">ID không hợp lệ!</c:when>
                                <c:when test="${param.error == 'voucher_not_found'}">Không tìm thấy voucher!</c:when>
                                <c:when test="${param.error == 'code_exists'}">Mã voucher đã tồn tại!</c:when>
                                <c:when test="${param.error == 'code_required'}">Mã voucher không được để trống!</c:when>
                                <c:when test="${param.error == 'invalid_percent'}">Giá trị phần trăm không được vượt quá 100%!</c:when>
                                <c:when test="${param.error == 'load_failed'}">Không thể tải dữ liệu!</c:when>
                                <c:otherwise>${param.error}</c:otherwise>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.success == 'add_success'}">Thêm voucher thành công!</c:when>
                                <c:when test="${param.success == 'update_success'}">Cập nhật voucher thành công!</c:when>
                                <c:when test="${param.success == 'delete_success'}">Xóa voucher thành công!</c:when>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${param.action == 'add' || param.action == 'edit'}">
                        <!-- Add/Edit Form -->
                        <form method="post" action="${pageContext.request.contextPath}/vlist?action=${param.action}">
                            <input type="hidden" name="action" value="${param.action}">
                            <c:if test="${param.action == 'edit'}">
                                <input type="hidden" name="voucherId" value="${voucher.voucherId}">
                            </c:if>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Mã Voucher <span class="text-danger">*</span></label>
                                    <c:choose>
                                        <c:when test="${param.action == 'edit'}">
                                            <input type="text" class="form-control" value="${voucher.code}" disabled>
                                            <small class="text-muted">Không thể thay đổi mã voucher sau khi tạo</small>
                                        </c:when>
                                        <c:otherwise>
                                            <input type="text" name="code" class="form-control" 
                                                   placeholder="VD: SUMMER2024" required 
                                                   pattern="[A-Z0-9]+" title="Chỉ chấp nhận chữ in hoa và số">
                                            <small class="text-muted">Chỉ chấp nhận chữ in hoa và số, không có khoảng trắng</small>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Loại giảm giá <span class="text-danger">*</span></label>
                                    <select name="discountType" class="form-select" required>
                                        <option value="PERCENT" ${voucher != null && voucher.discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm (%)</option>
                                        <option value="FIXED" ${voucher != null && voucher.discountType == 'FIXED' ? 'selected' : ''}>Số tiền cố định (VNĐ)</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Giá trị giảm giá <span class="text-danger">*</span></label>
                                    <input type="number" name="discountValue" class="form-control" 
                                           value="${voucher.discountValue}" step="0.01" min="0" required>
                                    <small class="text-muted">Nếu là phần trăm, nhập từ 0-100</small>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Giá trị đơn hàng tối thiểu</label>
                                    <input type="number" name="minOrderValue" class="form-control" 
                                           value="${voucher.minOrderValue}" step="0.01" min="0" placeholder="0">
                                    <small class="text-muted">Để 0 nếu không có yêu cầu tối thiểu</small>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Giới hạn sử dụng</label>
                                    <input type="number" name="usageLimit" class="form-control" 
                                           value="${voucher.usageLimit}" min="1" placeholder="Để trống = không giới hạn">
                                    <small class="text-muted">Số lần tối đa voucher có thể được sử dụng</small>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Ngày hết hạn</label>
                                    <input type="datetime-local" name="expiryDate" class="form-control" 
                                           value="<c:if test='${voucher.expiryDate != null}'><fmt:formatDate value='${voucher.expiryDate}' pattern='yyyy-MM-dd\'T\'HH:mm' /></c:if>">
                                    <small class="text-muted">Để trống nếu không có ngày hết hạn</small>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                    <select name="status" class="form-select" required>
                                        <option value="ACTIVE" ${voucher != null && voucher.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="INACTIVE" ${voucher != null && voucher.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                    </select>
                                </div>
                                
                                <c:if test="${param.action == 'edit' && voucher != null}">
                                    <div class="col-md-6">
                                        <label class="form-label">Đã sử dụng</label>
                                        <input type="text" class="form-control" 
                                               value="${voucher.usedCount} / ${voucher.usageLimit != null ? voucher.usageLimit : 'Unlimited'}" 
                                               disabled>
                                    </div>
                                </c:if>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-save"></i> Lưu
                                </button>
                                <a href="${pageContext.request.contextPath}/vlist" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </c:if>
                    
                    <c:if test="${empty param.action || param.action == 'list'}">
                        <!-- Filter Form -->
                        <form method="get" action="${pageContext.request.contextPath}/vlist" class="mb-4">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label">Tìm kiếm theo mã</label>
                                    <input type="text" name="keyword" class="form-control" 
                                           value="${keyword}" placeholder="Nhập mã voucher...">
                                </div>
                                
                                <div class="col-md-2">
                                    <label class="form-label">Trạng thái</label>
                                    <select name="status" class="form-select">
                                        <option value="ALL" ${status == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                        <option value="ACTIVE" ${status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-2">
                                    <label class="form-label">Loại giảm giá</label>
                                    <select name="discountType" class="form-select">
                                        <option value="ALL" ${discountType == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                        <option value="PERCENT" ${discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                                        <option value="FIXED" ${discountType == 'FIXED' ? 'selected' : ''}>Số tiền</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-2">
                                    <label class="form-label">Hạn sử dụng</label>
                                    <select name="expiryFilter" class="form-select">
                                        <option value="" ${expiryFilter == '' ? 'selected' : ''}>Tất cả</option>
                                        <option value="EXPIRING_SOON" ${expiryFilter == 'EXPIRING_SOON' ? 'selected' : ''}>Sắp hết hạn</option>
                                        <option value="EXPIRED" ${expiryFilter == 'EXPIRED' ? 'selected' : ''}>Đã hết hạn</option>
                                    </select>
                                </div>
                                
                                <div class="col-md-3">
                                    <label class="form-label">&nbsp;</label>
                                    <div class="d-flex gap-2">
                                        <button type="submit" class="btn btn-primary w-100">
                                            <i class="bi bi-search"></i> Tìm kiếm
                                        </button>
                                        <a href="${pageContext.request.contextPath}/vlist" class="btn btn-secondary">
                                            <i class="bi bi-arrow-clockwise"></i> Reset
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </form>
                        
                        <!-- Thông tin kết quả -->
                        <div class="mb-3 text-muted">
                            <small>Hiển thị ${vouchers != null ? vouchers.size() : 0} / ${totalCount != null ? totalCount : 0} voucher</small>
                        </div>
                        
                        <!-- Voucher List -->
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Mã Voucher</th>
                                        <th>Loại giảm</th>
                                        <th>Giá trị</th>
                                        <th>Đơn tối thiểu</th>
                                        <th>Sử dụng</th>
                                        <th>Hết hạn</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày tạo</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:if test="${not empty vouchers}">
                                        <c:forEach var="v" items="${vouchers}">
                                            <tr>
                                                <td>${v.voucherId}</td>
                                                <td><strong>${v.code}</strong></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.discountType == 'PERCENT'}">
                                                            <span class="badge bg-info">%</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-warning">VNĐ</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.discountType == 'PERCENT'}">
                                                            <fmt:formatNumber value="${v.discountValue}" maxFractionDigits="0" />%
                                                        </c:when>
                                                        <c:otherwise>
                                                            <fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.usageLimit != null}">
                                                            ${v.usedCount} / ${v.usageLimit}
                                                            <c:if test="${v.usedCount >= v.usageLimit}">
                                                                <span class="badge bg-danger ms-1">Hết</span>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            ${v.usedCount} / <span class="text-muted">Unlimited</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.expiryDate != null}">
                                                            <fmt:formatDate value="${v.expiryDate}" pattern="dd/MM/yyyy HH:mm" />
                                                            <c:set var="now" value="<%= new java.util.Date() %>" />
                                                            <c:if test="${v.expiryDate < now}">
                                                                <span class="badge expired-badge ms-1">Hết hạn</span>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">Không hết hạn</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${v.status == 'ACTIVE'}">
                                                            <span class="status-badge status-active">${v.status}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-inactive">${v.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${v.createdAt}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/vlist?action=edit&id=${v.voucherId}" class="btn btn-sm btn-warning btn-action">
                                                        <i class="bi bi-pencil"></i> Sửa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/vlist?action=delete&id=${v.voucherId}" 
                                                       class="btn btn-sm btn-danger btn-action"
                                                       onclick="return confirm('Bạn có chắc chắn muốn xóa voucher này?');">
                                                        <i class="bi bi-trash"></i> Xóa
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:if>
                                    <c:if test="${empty vouchers}">
                                        <tr>
                                            <td colspan="10" class="text-center text-muted py-4">
                                                <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                                                <p class="mt-2">Không tìm thấy voucher nào</p>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Phân trang -->
                        <c:if test="${totalPages > 1}">
                            <nav aria-label="Page navigation" class="mt-4">
                                <ul class="pagination justify-content-center">
                                    <!-- Nút Previous -->
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <c:choose>
                                            <c:when test="${currentPage > 1}">
                                                <a class="page-link" href="${pageContext.request.contextPath}/vlist?page=${currentPage - 1}&keyword=${keyword}&status=${status}&discountType=${discountType}&expiryFilter=${expiryFilter}">Trước</a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="page-link">Trước</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                    
                                    <!-- Các số trang -->
                                    <c:forEach var="i" begin="1" end="${totalPages}">
                                        <c:choose>
                                            <c:when test="${i == currentPage}">
                                                <li class="page-item active">
                                                    <span class="page-link">${i}</span>
                                                </li>
                                            </c:when>
                                            <c:when test="${i <= 3 || i > totalPages - 2 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                                <li class="page-item">
                                                    <a class="page-link" href="${pageContext.request.contextPath}/vlist?page=${i}&keyword=${keyword}&status=${status}&discountType=${discountType}&expiryFilter=${expiryFilter}">${i}</a>
                                                </li>
                                            </c:when>
                                            <c:when test="${i == currentPage - 2 || i == currentPage + 2}">
                                                <li class="page-item disabled">
                                                    <span class="page-link">...</span>
                                                </li>
                                            </c:when>
                                        </c:choose>
                                    </c:forEach>
                                    
                                    <!-- Nút Next -->
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <c:choose>
                                            <c:when test="${currentPage < totalPages}">
                                                <a class="page-link" href="${pageContext.request.contextPath}/vlist?page=${currentPage + 1}&keyword=${keyword}&status=${status}&discountType=${discountType}&expiryFilter=${expiryFilter}">Sau</a>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="page-link">Sau</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </li>
                                </ul>
                            </nav>
                        </c:if>
                    </c:if>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>

