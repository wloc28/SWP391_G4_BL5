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
            
            .status-expired {
                background-color: #fff3cd;
                color: #856404;
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
            
            .quantity-badge {
                display: inline-block;
                padding: 4px 10px;
                border-radius: 4px;
                font-size: 0.85rem;
                font-weight: 600;
                margin: 0 4px;
            }
            
            .quantity-total {
                background-color: #e7f3ff;
                color: #0066cc;
            }
            
            .quantity-available {
                background-color: #d1e7dd;
                color: #0f5132;
            }
            
            .quantity-sold {
                background-color: #cfe2ff;
                color: #084298;
            }
            
            .quantity-error {
                background-color: #f8d7da;
                color: #842029;
            }
            
            .quantity-expired {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .provider-badge {
                display: inline-block;
                padding: 4px 10px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 4px;
                font-size: 0.85rem;
                font-weight: 600;
                margin-right: 8px;
            }
            
            .modal-body .table {
                font-size: 0.9rem;
            }
            
            .modal-body .table th {
                background-color: #f8f9fa;
                font-weight: 600;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-archive"></i> Quản lý Kho hàng</span>
                </div>
                
                <div class="content-card-body">
                    <!-- Error/Success Messages -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <!-- Search/Filter Form -->
                    <div class="search-form">
                        <form method="get" action="${pageContext.request.contextPath}/pklist" onsubmit="document.getElementById('pageInput').value='1'">
                            <input type="hidden" name="page" value="1" id="pageInput">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">Nhà cung cấp</label>
                                    <select name="providerName" class="form-select">
                                        <option value="">-- Tất cả nhà cung cấp --</option>
                                        <c:forEach var="name" items="${providerNames}">
                                            <option value="${name}" ${selectedProviderName == name ? 'selected' : ''}>
                                                ${name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Trạng thái</label>
                                    <select name="status" class="form-select">
                                        <option value="">-- Tất cả trạng thái --</option>
                                        <option value="AVAILABLE" ${selectedStatus == 'AVAILABLE' ? 'selected' : ''}>AVAILABLE</option>
                                        <option value="SOLD" ${selectedStatus == 'SOLD' ? 'selected' : ''}>SOLD</option>
                                        <option value="ERROR" ${selectedStatus == 'ERROR' ? 'selected' : ''}>ERROR</option>
                                        <option value="EXPIRED" ${selectedStatus == 'EXPIRED' ? 'selected' : ''}>EXPIRED</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Số lượng/trang</label>
                                    <select name="pageSize" class="form-select" onchange="this.form.submit()">
                                        <option value="5" ${selectedPageSize == '5' || empty selectedPageSize ? 'selected' : ''}>5</option>
                                        <option value="10" ${selectedPageSize == '10' ? 'selected' : ''}>10</option>
                                        <option value="15" ${selectedPageSize == '15' ? 'selected' : ''}>15</option>
                                    </select>
                                </div>
                                <div class="col-md-3 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-search"></i> Lọc
                                    </button>
                                    <a href="${pageContext.request.contextPath}/pklist" class="btn btn-secondary">
                                        <i class="bi bi-arrow-clockwise"></i> Reset
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Storage Groups List -->
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Nhà cung cấp</th>
                                    <th>Mã sản phẩm</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Giá bán</th>
                                    <th>Số lượng</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${not empty storageGroups}">
                                    <c:forEach var="group" items="${storageGroups}">
                                        <tr>
                                            <td>
                                                <span class="provider-badge">${group.providerName}</span>
                                            </td>
                                            <td><strong>${group.productCode}</strong></td>
                                            <td>${group.productName}</td>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <input type="number" 
                                                           class="form-control form-control-sm price-input" 
                                                           value="<fmt:formatNumber value="${group.price}" type="number" maxFractionDigits="0" groupingUsed="false"/>" 
                                                           data-product-code="${group.productCode}" 
                                                           data-provider-id="${group.providerId}"
                                                           data-original-price="<fmt:formatNumber value="${group.price}" type="number" maxFractionDigits="0" groupingUsed="false"/>"
                                                           style="width: 120px; display: inline-block;"
                                                           onblur="updatePrice('${group.productCode}', ${group.providerId}, this.value, this)"
                                                           onkeypress="if(event.key === 'Enter') { this.blur(); }"
                                                           min="0"
                                                           max="1000000"
                                                           step="1000">
                                                    <span>đ</span>
                                                    <button type="button" 
                                                            class="btn btn-sm btn-outline-primary" 
                                                            onclick="editPrice('${group.productCode}', ${group.providerId})"
                                                            title="Chỉnh sửa giá">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                </div>
                                            </td>
                                            <td>
                                                <div>
                                                    <span class="quantity-badge quantity-total">Tổng: ${group.totalQuantity}</span>
                                                    <span class="quantity-badge quantity-available">Có: ${group.availableQuantity}</span>
                                                    <c:if test="${group.soldQuantity > 0}">
                                                        <span class="quantity-badge quantity-sold">Đã bán: ${group.soldQuantity}</span>
                                                    </c:if>
                                                    <c:if test="${group.errorQuantity > 0}">
                                                        <span class="quantity-badge quantity-error">Lỗi: ${group.errorQuantity}</span>
                                                    </c:if>
                                                    <c:if test="${group.expiredQuantity > 0}">
                                                        <span class="quantity-badge quantity-expired">Hết hạn: ${group.expiredQuantity}</span>
                                                    </c:if>
                                                </div>
                                            </td>
                                            <td>
                                                <select class="form-select form-select-sm" 
                                                        style="width: auto; display: inline-block;"
                                                        onchange="updateProductStatus('${group.productCode}', ${group.providerId}, this.value)"
                                                        id="status_${group.productCode}_${group.providerId}">
                                                    <option value="ACTIVE" ${group.productStatus == 'ACTIVE' ? 'selected' : ''}>Đang bán</option>
                                                    <option value="INACTIVE" ${group.productStatus == 'INACTIVE' ? 'selected' : ''}>Ngừng bán</option>
                                                </select>
                                            </td>
                                            <td>
                                                <button type="button" 
                                                        class="btn btn-primary btn-sm btn-action" 
                                                        onclick="showCardDetails('${group.productCode}', '${group.productName}', '${group.providerName}')">
                                                    <i class="bi bi-eye"></i> Chi tiết
                                                </button>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty storageGroups}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">
                                            <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                                            <p class="mt-2">Chưa có sản phẩm nào trong kho</p>
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination Info -->
                    <c:if test="${not empty totalCount && totalCount > 0}">
                        <div class="d-flex justify-content-between align-items-center mt-3 mb-3">
                            <div class="text-muted">
                                Hiển thị <strong>${startItem}</strong> - <strong>${endItem}</strong> trong tổng số <strong>${totalCount}</strong> bản ghi
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- Pagination -->
                    <c:if test="${not empty totalPages && totalPages > 1}">
                        <nav aria-label="Page navigation">
                            <ul class="pagination justify-content-center">
                                <!-- Previous Button -->
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <c:url var="prevUrl" value="/pklist">
                                        <c:param name="page" value="${currentPage - 1}"/>
                                        <c:param name="pageSize" value="${pageSize}"/>
                                        <c:if test="${not empty selectedProviderName}">
                                            <c:param name="providerName" value="${selectedProviderName}"/>
                                        </c:if>
                                        <c:if test="${not empty selectedStatus}">
                                            <c:param name="status" value="${selectedStatus}"/>
                                        </c:if>
                                    </c:url>
                                    <a class="page-link" href="${prevUrl}" ${currentPage == 1 ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                        <i class="bi bi-chevron-left"></i> Trước
                                    </a>
                                </li>
                                
                                <!-- Page Numbers -->
                                <c:choose>
                                    <c:when test="${totalPages <= 7}">
                                        <c:forEach var="i" begin="1" end="${totalPages}">
                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                <c:url var="pageUrl" value="/pklist">
                                                    <c:param name="page" value="${i}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}">
                                                        <c:param name="providerName" value="${selectedProviderName}"/>
                                                    </c:if>
                                                    <c:if test="${not empty selectedStatus}">
                                                        <c:param name="status" value="${selectedStatus}"/>
                                                    </c:if>
                                                </c:url>
                                                <a class="page-link" href="${pageUrl}">${i}</a>
                                            </li>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <c:url var="firstUrl" value="/pklist">
                                                    <c:param name="page" value="1"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                                                </c:url>
                                                <a class="page-link" href="${firstUrl}">1</a>
                                            </li>
                                            <c:if test="${currentPage > 3}">
                                                <li class="page-item disabled">
                                                    <span class="page-link">...</span>
                                                </li>
                                            </c:if>
                                        </c:if>
                                        
                                        <c:forEach var="i" begin="${currentPage > 2 ? currentPage - 1 : 2}" 
                                                   end="${currentPage < totalPages - 1 ? currentPage + 1 : totalPages - 1}">
                                            <li class="page-item ${i == currentPage ? 'active' : ''}">
                                                <c:url var="pageUrl" value="/pklist">
                                                    <c:param name="page" value="${i}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                                                </c:url>
                                                <a class="page-link" href="${pageUrl}">${i}</a>
                                            </li>
                                        </c:forEach>
                                        
                                        <c:if test="${currentPage < totalPages}">
                                            <c:if test="${currentPage < totalPages - 2}">
                                                <li class="page-item disabled">
                                                    <span class="page-link">...</span>
                                                </li>
                                            </c:if>
                                            <li class="page-item">
                                                <c:url var="lastUrl" value="/pklist">
                                                    <c:param name="page" value="${totalPages}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty selectedStatus}"><c:param name="status" value="${selectedStatus}"/></c:if>
                                                </c:url>
                                                <a class="page-link" href="${lastUrl}">${totalPages}</a>
                                            </li>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Next Button -->
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <c:url var="nextUrl" value="/pklist">
                                        <c:param name="page" value="${currentPage + 1}"/>
                                        <c:param name="pageSize" value="${pageSize}"/>
                                        <c:if test="${not empty selectedProviderName}">
                                            <c:param name="providerName" value="${selectedProviderName}"/>
                                        </c:if>
                                        <c:if test="${not empty selectedStatus}">
                                            <c:param name="status" value="${selectedStatus}"/>
                                        </c:if>
                                    </c:url>
                                    <a class="page-link" href="${nextUrl}" ${currentPage == totalPages ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                        Sau <i class="bi bi-chevron-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                    </c:if>
                </div>
            </div>
        </div>
        
        <!-- Card Details Modal -->
        <div class="modal fade" id="cardDetailsModal" tabindex="-1">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">
                            <i class="bi bi-list-ul"></i> Chi tiết mã thẻ: <span id="modalProductCode"></span>
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <strong>Sản phẩm:</strong> <span id="modalProductName"></span><br>
                            <strong>Nhà cung cấp:</strong> <span id="modalProviderName"></span>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-striped table-hover">
                                <thead>
                                    <tr>
                                        <th>STT</th>
                                        <th>Serial Number</th>
                                        <th>Card Code</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày hết hạn</th>
                                        <th>Ngày tạo</th>
                                    </tr>
                                </thead>
                                <tbody id="cardDetailsBody">
                                    <tr>
                                        <td colspan="6" class="text-center">
                                            <div class="spinner-border spinner-border-sm" role="status">
                                                <span class="visually-hidden">Loading...</span>
                                            </div>
                                            Đang tải...
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    </div>
                </div>
            </div>
        </div>
        
        <script>
            function updateProductStatus(productCode, providerId, status) {
                if (!confirm('Bạn có chắc chắn muốn thay đổi trạng thái sản phẩm này?')) {
                    // Reset dropdown về giá trị cũ
                    location.reload();
                    return;
                }
                
                fetch('${pageContext.request.contextPath}/pklist', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'action=updateStatus&productCode=' + encodeURIComponent(productCode) + 
                          '&providerId=' + providerId + 
                          '&status=' + encodeURIComponent(status)
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('Cập nhật trạng thái thành công!');
                        location.reload();
                    } else {
                        alert('Lỗi: ' + (data.error || 'Không thể cập nhật trạng thái'));
                        location.reload();
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    alert('Lỗi khi cập nhật trạng thái');
                    location.reload();
                });
            }
            
            function showCardDetails(productCode, productName, providerName) {
                // Set modal title
                document.getElementById('modalProductCode').textContent = productCode;
                document.getElementById('modalProductName').textContent = productName;
                document.getElementById('modalProviderName').textContent = providerName;
                
                // Show loading
                document.getElementById('cardDetailsBody').innerHTML = 
                    '<tr><td colspan="6" class="text-center"><div class="spinner-border spinner-border-sm" role="status"><span class="visually-hidden">Loading...</span></div> Đang tải...</td></tr>';
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('cardDetailsModal'));
                modal.show();
                
                // Load card details via AJAX
                fetch('${pageContext.request.contextPath}/pklist?action=details&productCode=' + encodeURIComponent(productCode))
                    .then(response => response.json())
                    .then(data => {
                        if (data.error) {
                            document.getElementById('cardDetailsBody').innerHTML = 
                                '<tr><td colspan="6" class="text-center text-danger">' + data.error + '</td></tr>';
                            return;
                        }
                        
                        if (data.length === 0) {
                            document.getElementById('cardDetailsBody').innerHTML = 
                                '<tr><td colspan="6" class="text-center text-muted">Không có thẻ nào</td></tr>';
                            return;
                        }
                        
                        let html = '';
                        data.forEach((card, index) => {
                            const statusClass = getStatusClass(card.status);
                            const expiryDate = card.expiryDate ? formatDate(card.expiryDate) : '-';
                            const createdAt = card.createdAt ? formatDateTime(card.createdAt) : '-';
                            
                            html += '<tr>';
                            html += '<td>' + (index + 1) + '</td>';
                            html += '<td><code>' + escapeHtml(card.serialNumber) + '</code></td>';
                            html += '<td><code>' + escapeHtml(card.cardCode) + '</code></td>';
                            html += '<td><span class="status-badge ' + statusClass + '">' + escapeHtml(card.status) + '</span></td>';
                            html += '<td>' + expiryDate + '</td>';
                            html += '<td>' + createdAt + '</td>';
                            html += '</tr>';
                        });
                        
                        document.getElementById('cardDetailsBody').innerHTML = html;
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        document.getElementById('cardDetailsBody').innerHTML = 
                            '<tr><td colspan="6" class="text-center text-danger">Lỗi khi tải dữ liệu</td></tr>';
                    });
            }
            
            function getStatusClass(status) {
                switch(status) {
                    case 'AVAILABLE': return 'status-available';
                    case 'SOLD': return 'status-sold';
                    case 'ERROR': return 'status-error';
                    case 'EXPIRED': return 'status-expired';
                    default: return '';
                }
            }
            
            function formatDate(dateStr) {
                if (!dateStr) return '-';
                const date = new Date(dateStr);
                return date.toLocaleDateString('vi-VN');
            }
            
            function formatDateTime(dateTimeStr) {
                if (!dateTimeStr) return '-';
                const date = new Date(dateTimeStr);
                return date.toLocaleString('vi-VN');
            }
            
            function escapeHtml(text) {
                const map = {
                    '&': '&amp;',
                    '<': '&lt;',
                    '>': '&gt;',
                    '"': '&quot;',
                    "'": '&#039;'
                };
                return text ? text.replace(/[&<>"']/g, m => map[m]) : '';
            }
            
            function updatePrice(productCode, providerId, newPrice, inputElement) {
                // Lấy giá gốc
                const originalPrice = inputElement.getAttribute('data-original-price');
                
                // Validate giá
                if (!newPrice || newPrice <= 0) {
                    alert('Giá bán phải lớn hơn 0!');
                    inputElement.value = originalPrice;
                    return;
                }
                
                // Validate giá tối đa 1.000.000
                if (parseFloat(newPrice) > 1000000) {
                    alert('Giá bán không được vượt quá 1.000.000 đ!');
                    inputElement.value = originalPrice;
                    return;
                }
                
                // Kiểm tra xem giá có thay đổi không
                if (parseFloat(newPrice) === parseFloat(originalPrice)) {
                    return; // Không có thay đổi, không cần cập nhật
                }
                
                if (!confirm('Bạn có chắc chắn muốn cập nhật giá bán cho sản phẩm ' + productCode + ' từ ' + 
                            formatNumber(originalPrice) + ' đ thành ' + formatNumber(newPrice) + ' đ?')) {
                    inputElement.value = originalPrice;
                    return;
                }
                
                // Disable input trong khi đang xử lý
                inputElement.disabled = true;
                
                fetch('${pageContext.request.contextPath}/pklist', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'action=updatePrice&productCode=' + encodeURIComponent(productCode) + 
                          '&providerId=' + providerId + 
                          '&price=' + encodeURIComponent(newPrice)
                })
                .then(response => response.json())
                .then(data => {
                    inputElement.disabled = false;
                    if (data.success) {
                        alert('Cập nhật giá bán thành công!');
                        // Cập nhật giá gốc
                        inputElement.setAttribute('data-original-price', newPrice);
                        location.reload();
                    } else {
                        alert('Lỗi: ' + (data.error || 'Không thể cập nhật giá bán'));
                        inputElement.value = originalPrice;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    inputElement.disabled = false;
                    alert('Lỗi khi cập nhật giá bán');
                    inputElement.value = originalPrice;
                });
            }
            
            function editPrice(productCode, providerId) {
                const input = document.querySelector(`input[data-product-code="${productCode}"][data-provider-id="${providerId}"]`);
                if (input) {
                    input.focus();
                    input.select();
                }
            }
            
            function formatNumber(num) {
                return parseFloat(num).toLocaleString('vi-VN');
            }
        </script>
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
