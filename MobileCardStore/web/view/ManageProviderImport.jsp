<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản Lý Nhập Hàng Từ Nhà Cung Cấp</title>
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
            
            .status-high {
                background-color: #d1e7dd;
                color: #0f5132;
            }
            
            .status-medium {
                background-color: #fff3cd;
                color: #856404;
            }
            
            .status-low {
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
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-truck"></i> Quản Lý Nhập Hàng Từ Nhà Cung Cấp</span>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/pklist" class="btn btn-outline-success">
                            <i class="bi bi-archive"></i> Tiến đến kho hàng
                        </a>
                        <a href="provider-import?action=history" class="btn btn-outline-primary">
                            <i class="bi bi-clock-history"></i> Lịch sử nhập hàng
                        </a>
                    </div>
                </div>
                
                <div class="content-card-body">
                    <!-- Alert Messages -->
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.error == 'insufficient_quantity'}">Số lượng hàng ở provider không đủ!</c:when>
                                <c:when test="${param.error == 'provider_not_found'}">Không tìm thấy sản phẩm provider!</c:when>
                                <c:when test="${param.error == 'product_not_found'}">Không tìm thấy sản phẩm trong hệ thống!</c:when>
                                <c:when test="${param.error == 'import_failed'}">Nhập hàng thất bại. Vui lòng thử lại!</c:when>
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
                                <c:when test="${param.success == 'import_success'}">Nhập hàng thành công!</c:when>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <!-- Search Form -->
                    <div class="search-form">
                        <form method="GET" action="provider-import">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">Chọn nhà cung cấp</label>
                                    <select name="providerName" class="form-select">
                                        <option value="">-- Tất cả nhà cung cấp --</option>
                                        <c:forEach var="name" items="${providerNames}">
                                            <option value="${name}" ${selectedProviderName == name ? 'selected' : ''}>
                                                ${name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-8 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-search"></i> Tìm kiếm
                                    </button>
                                    <a href="${pageContext.request.contextPath}/provider-import" class="btn btn-secondary">
                                        <i class="bi bi-arrow-clockwise"></i> Reset
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Provider Products List -->
                    <c:choose>
                        <c:when test="${empty providerProducts}">
                            <div class="alert alert-info">
                                <i class="bi bi-info-circle me-2"></i>Không có sản phẩm nào từ nhà cung cấp.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Nhà cung cấp</th>
                                        <th>Mã SP</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Giá nhập</th>
                                        <th>Giá bán</th>
                                        <th>Số lượng còn</th>
                                        <th>Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="entry" items="${providerProducts}">
                                        <c:set var="providerName" value="${entry.key}" />
                                        <c:set var="products" value="${entry.value}" />
                                        <c:forEach var="pp" items="${products}">
                                            <tr>
                                                <td>
                                                    <span class="provider-badge">${providerName}</span>
                                                </td>
                                                <td><strong>${pp.productCode}</strong></td>
                                                <td>${pp.productName}</td>
                                                <td>
                                                    <fmt:formatNumber value="${pp.purchasePrice}" type="number" maxFractionDigits="0"/> đ
                                                </td>
                                                <td>
                                                    <fmt:formatNumber value="${pp.price}" type="number" maxFractionDigits="0"/> đ
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${pp.availableQuantity > 50}">
                                                            <span class="status-badge status-high">${pp.availableQuantity}</span>
                                                        </c:when>
                                                        <c:when test="${pp.availableQuantity > 10}">
                                                            <span class="status-badge status-medium">${pp.availableQuantity}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-low">${pp.availableQuantity}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <button type="button" 
                                                            class="btn btn-primary btn-action" 
                                                            onclick="showImportModal(${pp.providerStorageId}, '${pp.productCode}', '${pp.productName}', ${pp.availableQuantity}, ${pp.purchasePrice}, ${pp.price})"
                                                            ${pp.availableQuantity == 0 ? 'disabled' : ''}>
                                                        <i class="bi bi-box-arrow-in-down"></i> Nhập hàng
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
        
        <!-- Import Modal -->
        <div class="modal fade" id="importModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Nhập hàng từ nhà cung cấp</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <form method="POST" action="provider-import" id="importForm">
                        <input type="hidden" name="action" value="import">
                        <input type="hidden" name="providerStorageId" id="modalProviderStorageId">
                        
                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Mã sản phẩm:</label>
                                <input type="text" class="form-control" id="modalProductCode" readonly>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Tên sản phẩm:</label>
                                <input type="text" class="form-control" id="modalProductName" readonly>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Giá nhập:</label>
                                <input type="text" class="form-control" id="modalPurchasePrice" readonly>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Số lượng còn ở provider:</label>
                                <input type="text" class="form-control" id="modalAvailableQuantity" readonly>
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Số lượng nhập: <span class="text-danger">*</span></label>
                                <input type="number" name="quantity" id="modalQuantity" 
                                       class="form-control" min="1" required 
                                       onchange="calculateTotal()">
                            </div>
                            
                            <div class="mb-3">
                                <label class="form-label">Tổng chi phí:</label>
                                <input type="text" class="form-control" id="modalTotalCost" readonly>
                            </div>
                        </div>
                        
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button type="submit" class="btn btn-primary">Xác nhận nhập hàng</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <script>
            function showImportModal(providerStorageId, productCode, productName, availableQuantity, purchasePrice, salePrice) {
                // Set modal values
                document.getElementById('modalProviderStorageId').value = providerStorageId;
                document.getElementById('modalProductCode').value = productCode;
                document.getElementById('modalProductName').value = productName;
                document.getElementById('modalPurchasePrice').value = formatCurrency(purchasePrice);
                document.getElementById('modalAvailableQuantity').value = availableQuantity;
                document.getElementById('modalQuantity').max = availableQuantity;
                document.getElementById('modalQuantity').value = '';
                document.getElementById('modalTotalCost').value = '';
                
                // Show modal
                const modal = new bootstrap.Modal(document.getElementById('importModal'));
                modal.show();
            }
            
            function calculateTotal() {
                const quantity = parseInt(document.getElementById('modalQuantity').value) || 0;
                const purchasePrice = parseFloat(document.getElementById('modalPurchasePrice').value.replace(/[^\d.]/g, '')) || 0;
                const total = quantity * purchasePrice;
                
                document.getElementById('modalTotalCost').value = formatCurrency(total);
            }
            
            function formatCurrency(amount) {
                return new Intl.NumberFormat('vi-VN').format(amount) + ' đ';
            }
            
            // Validate form before submit
            document.getElementById('importForm').addEventListener('submit', function(e) {
                const quantity = parseInt(document.getElementById('modalQuantity').value);
                const availableQuantity = parseInt(document.getElementById('modalAvailableQuantity').value);
                
                if (quantity <= 0) {
                    e.preventDefault();
                    alert('Số lượng nhập phải lớn hơn 0!');
                    return false;
                }
                
                if (quantity > availableQuantity) {
                    e.preventDefault();
                    alert('Số lượng nhập không được vượt quá số lượng còn lại!');
                    return false;
                }
                
                return true;
            });
        </script>
    </body>
</html>

