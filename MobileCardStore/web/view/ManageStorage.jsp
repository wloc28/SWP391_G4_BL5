<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý Kho hàng</title>
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
            
            .status-available {
                background-color: #d1e7dd;
                color: #0f5132;
            }
            
            .status-sold {
                background-color: #cfe2ff;
                color: #084298;
            }
            
            .status-error {
                background-color: #f8d7da;
                color: #842029;
            }
            
            .btn-action {
                padding: 5px 10px;
                margin: 0 2px;
                font-size: 0.85rem;
            }
            
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
            
            .pagination-wrapper {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 20px;
                padding-top: 20px;
                border-top: 1px solid #dee2e6;
            }
            
            .pagination-info {
                color: #6c757d;
                font-size: 0.9rem;
            }
            
            .pagination {
                margin: 0;
            }
            
            .pagination .page-link {
                color: #0d6efd;
                border: 1px solid #dee2e6;
                padding: 8px 12px;
                margin: 0 2px;
                border-radius: 4px;
                transition: all 0.3s;
            }
            
            .pagination .page-link:hover {
                background-color: #e7f1ff;
                border-color: #0d6efd;
            }
            
            .pagination .page-item.active .page-link {
                background-color: #0d6efd;
                border-color: #0d6efd;
                color: white;
                font-weight: 600;
            }
            
            .pagination .page-item.disabled .page-link {
                color: #6c757d;
                background-color: #e9ecef;
                border-color: #dee2e6;
                cursor: not-allowed;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-archive"></i> Quản lý Kho hàng</span>
                    <a href="${pageContext.request.contextPath}/pklist?action=add" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Thêm thẻ mới
                    </a>
                </div>
                
                <div class="content-card-body">
                    <!-- Search Form -->
                    <c:if test="${empty param.action || param.action == 'list'}">
                        <div class="search-form">
                            <form method="get" action="${pageContext.request.contextPath}/pklist">
                                <input type="hidden" name="action" value="list">
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label">Tìm kiếm theo tên</label>
                                        <input type="text" name="searchKeyword" class="form-control" 
                                               placeholder="Nhập tên sản phẩm, serial, card code..." 
                                               value="${searchKeyword}">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select">
                                            <option value="ALL" ${empty selectedStatus || selectedStatus == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                            <option value="AVAILABLE" ${selectedStatus == 'AVAILABLE' ? 'selected' : ''}>AVAILABLE</option>
                                            <option value="SOLD" ${selectedStatus == 'SOLD' ? 'selected' : ''}>SOLD</option>
                                            <option value="ERROR" ${selectedStatus == 'ERROR' ? 'selected' : ''}>ERROR</option>
                                        </select>
                                    </div>
                                    <div class="col-md-5 d-flex align-items-end gap-2">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-search"></i> Tìm kiếm
                                        </button>
                                        <a href="${pageContext.request.contextPath}/pklist" class="btn btn-secondary">
                                            <i class="bi bi-arrow-clockwise"></i> Reset
                                        </a>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.error == 'add_failed'}">Thêm item thất bại!</c:when>
                                <c:when test="${param.error == 'update_failed'}">Cập nhật item thất bại!</c:when>
                                <c:when test="${param.error == 'delete_failed'}">Xóa item thất bại!</c:when>
                                <c:when test="${param.error == 'invalid_id'}">ID không hợp lệ!</c:when>
                                <c:when test="${param.error == 'item_not_found'}">Không tìm thấy item!</c:when>
                                <c:otherwise>${param.error}</c:otherwise>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.success == 'add_success'}">Thêm item thành công!</c:when>
                                <c:when test="${param.success == 'update_success'}">Cập nhật item thành công!</c:when>
                                <c:when test="${param.success == 'delete_success'}">Xóa item thành công!</c:when>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${param.action == 'add' || param.action == 'edit'}">
                        <!-- Add/Edit Form -->
                        <form method="post" action="${pageContext.request.contextPath}/pklist?action=${param.action}">
                            <input type="hidden" name="action" value="${param.action}">
                            <c:if test="${param.action == 'edit'}">
                                <input type="hidden" name="storageId" value="${storageItem.storageId}">
                            </c:if>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Sản phẩm <span class="text-danger">*</span></label>
                                    <select name="productId" class="form-select" required>
                                        <option value="">-- Chọn sản phẩm --</option>
                                        <c:forEach var="product" items="${products}">
                                            <option value="${product.productId}" 
                                                    ${storageItem != null && storageItem.productId == product.productId ? 'selected' : ''}>
                                                ${product.productName} - 
                                                <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                    <select name="status" class="form-select" required>
                                        <option value="AVAILABLE" ${storageItem != null && storageItem.status == 'AVAILABLE' ? 'selected' : ''}>AVAILABLE</option>
                                        <option value="SOLD" ${storageItem != null && storageItem.status == 'SOLD' ? 'selected' : ''}>SOLD</option>
                                        <option value="ERROR" ${storageItem != null && storageItem.status == 'ERROR' ? 'selected' : ''}>ERROR</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Serial Number <span class="text-danger">*</span></label>
                                    <input type="text" name="serialNumber" class="form-control" 
                                           value="${storageItem.serialNumber}" required>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Card Code <span class="text-danger">*</span></label>
                                    <input type="text" name="cardCode" class="form-control" 
                                           value="${storageItem.cardCode}" required>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Ngày hết hạn</label>
                                    <input type="date" name="expiryDate" class="form-control" 
                                           value="${storageItem.expiryDate}">
                                </div>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-save"></i> Lưu
                                </button>
                                <a href="${pageContext.request.contextPath}/pklist" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </c:if>
                    
                    <c:if test="${empty param.action || param.action == 'list'}">
                        <!-- Storage Items List -->
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Sản phẩm</th>
                                        <th>Serial Number</th>
                                        <th>Card Code</th>
                                        <th>Ngày hết hạn</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày tạo</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:if test="${not empty storageItems}">
                                        <c:forEach var="item" items="${storageItems}">
                                            <tr>
                                                <td>${item.storageId}</td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.product}">
                                                            <strong>${item.product.productName}</strong>
                                                        </c:when>
                                                        <c:otherwise>
                                                            Product #${item.productId}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><code>${item.serialNumber}</code></td>
                                                <td><code>${item.cardCode}</code></td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty item.expiryDate}">
                                                            <fmt:formatDate value="${item.expiryDate}" pattern="dd/MM/yyyy" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted">-</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${item.status == 'AVAILABLE'}">
                                                            <span class="status-badge status-available">${item.status}</span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'SOLD'}">
                                                            <span class="status-badge status-sold">${item.status}</span>
                                                        </c:when>
                                                        <c:when test="${item.status == 'ERROR'}">
                                                            <span class="status-badge status-error">${item.status}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge">${item.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/pklist?action=edit&id=${item.storageId}" class="btn btn-sm btn-warning btn-action">
                                                        <i class="bi bi-pencil"></i> Sửa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/pklist?action=delete&id=${item.storageId}" 
                                                       class="btn btn-sm btn-danger btn-action"
                                                       onclick="return confirm('Bạn có chắc chắn muốn xóa item này?');">
                                                        <i class="bi bi-trash"></i> Xóa
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:if>
                                    <c:if test="${empty storageItems}">
                                        <tr>
                                            <td colspan="8" class="text-center text-muted py-4">
                                                <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                                                <p class="mt-2">Chưa có item nào trong kho</p>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Pagination -->
                        <c:if test="${totalPages > 1}">
                            <div class="pagination-wrapper">
                                <div class="pagination-info">
                                    Hiển thị ${(currentPage - 1) * itemsPerPage + 1} - 
                                    ${currentPage * itemsPerPage > totalItems ? totalItems : currentPage * itemsPerPage} 
                                    trong tổng số ${totalItems} items
                                </div>
                                
                                <nav>
                                    <ul class="pagination">
                                        <!-- Previous Button -->
                                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                            <a class="page-link" 
                                               href="?page=${currentPage - 1}&searchKeyword=${searchKeyword}&status=${selectedStatus}" 
                                               ${currentPage == 1 ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                                <i class="bi bi-chevron-left"></i> Trước
                                            </a>
                                        </li>
                                        
                                        <!-- Page Numbers -->
                                        <c:forEach var="i" begin="1" end="${totalPages}">
                                            <c:choose>
                                                <c:when test="${i == currentPage}">
                                                    <li class="page-item active">
                                                        <span class="page-link">${i}</span>
                                                    </li>
                                                </c:when>
                                                <c:when test="${i == 1 || i == totalPages || (i >= currentPage - 2 && i <= currentPage + 2)}">
                                                    <li class="page-item">
                                                        <a class="page-link" href="?page=${i}&searchKeyword=${searchKeyword}&status=${selectedStatus}">${i}</a>
                                                    </li>
                                                </c:when>
                                                <c:when test="${i == currentPage - 3 || i == currentPage + 3}">
                                                    <li class="page-item disabled">
                                                        <span class="page-link">...</span>
                                                    </li>
                                                </c:when>
                                            </c:choose>
                                        </c:forEach>
                                        
                                        <!-- Next Button -->
                                        <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                            <a class="page-link" 
                                               href="?page=${currentPage + 1}&searchKeyword=${searchKeyword}&status=${selectedStatus}"
                                               ${currentPage == totalPages ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                                Sau <i class="bi bi-chevron-right"></i>
                                            </a>
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                        </c:if>
                    </c:if>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>

