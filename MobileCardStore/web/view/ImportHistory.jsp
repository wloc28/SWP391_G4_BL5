<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lịch Sử Nhập Hàng</title>
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
            
            .total-cost-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }
            
            .total-cost-card h5 {
                margin: 0;
                font-size: 0.9rem;
                opacity: 0.9;
            }
            
            .total-cost-card .amount {
                font-size: 2rem;
                font-weight: 700;
                margin-top: 10px;
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
                    <span><i class="bi bi-clock-history"></i> Lịch Sử Nhập Hàng</span>
                    <div class="d-flex gap-2">
                        <a href="${pageContext.request.contextPath}/pklist" class="btn btn-outline-success">
                            <i class="bi bi-archive"></i> Tiến đến kho hàng
                        </a>
                        <a href="${pageContext.request.contextPath}/provider-import" class="btn btn-outline-secondary">
                            <i class="bi bi-arrow-left"></i> Quay lại
                        </a>
                    </div>
                </div>
                
                <div class="content-card-body">
                    <!-- Error Message -->
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            ${error}
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <!-- Total Cost Card -->
                    <c:if test="${not empty totalCost}">
                        <div class="total-cost-card">
                            <h5><i class="bi bi-cash-stack"></i> Tổng chi phí nhập hàng</h5>
                            <div class="amount">
                                <fmt:formatNumber value="${totalCost}" type="number" maxFractionDigits="0"/> đ
                            </div>
                        </div>
                    </c:if>
                    
                    <!-- Search/Filter Form -->
                    <div class="search-form">
                        <form method="get" action="${pageContext.request.contextPath}/provider-import" onsubmit="document.getElementById('pageInput').value='1'">
                            <input type="hidden" name="action" value="history">
                            <input type="hidden" name="page" value="1" id="pageInput">
                            <div class="row g-3">
                                <div class="col-md-3">
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
                                    <label class="form-label">Từ ngày</label>
                                    <input type="date" name="fromDate" class="form-control" value="${fromDate}">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Đến ngày</label>
                                    <input type="date" name="toDate" class="form-control" value="${toDate}">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Số lượng/trang</label>
                                    <select name="pageSize" class="form-select" onchange="this.form.submit()">
                                        <option value="5" ${selectedPageSize == '5' || empty selectedPageSize ? 'selected' : ''}>5</option>
                                        <option value="10" ${selectedPageSize == '10' ? 'selected' : ''}>10</option>
                                        <option value="15" ${selectedPageSize == '15' ? 'selected' : ''}>15</option>
                                    </select>
                                </div>
                                <div class="col-md-2 d-flex align-items-end gap-2">
                                    <button type="submit" class="btn btn-primary">
                                        <i class="bi bi-search"></i> Lọc
                                    </button>
                                    <a href="${pageContext.request.contextPath}/provider-import?action=history" class="btn btn-secondary">
                                        <i class="bi bi-arrow-clockwise"></i> Reset
                                    </a>
                                </div>
                            </div>
                        </form>
                    </div>
                    
                    <!-- Import History Table -->
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>STT</th>
                                    <th>Ngày nhập</th>
                                    <th>Nhà cung cấp</th>
                                    <th>Mã sản phẩm</th>
                                    <th>Tên sản phẩm</th>
                                    <th>Số lượng</th>
                                    <th>Giá nhập</th>
                                    <th>Tổng chi phí</th>
                                    <th>Ghi chú</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${not empty importHistory}">
                                    <c:forEach var="transaction" items="${importHistory}" varStatus="status">
                                        <tr>
                                            <td>${(currentPage - 1) * pageSize + status.index + 1}</td>
                                            <td>
                                                <fmt:formatDate value="${transaction.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </td>
                                            <td>
                                                <c:if test="${not empty transaction.providerStorage}">
                                                    <c:if test="${not empty transaction.providerStorage.provider}">
                                                        <span class="provider-badge">${transaction.providerStorage.provider.providerName}</span>
                                                    </c:if>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:if test="${not empty transaction.providerStorage}">
                                                    <strong>${transaction.providerStorage.productCode}</strong>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:if test="${not empty transaction.providerStorage}">
                                                    ${transaction.providerStorage.productName}
                                                </c:if>
                                            </td>
                                            <td>
                                                <strong>${transaction.quantity}</strong>
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${transaction.purchasePrice}" type="number" maxFractionDigits="0"/> đ
                                            </td>
                                            <td>
                                                <strong style="color: #dc3545;">
                                                    <fmt:formatNumber value="${transaction.totalCost}" type="number" maxFractionDigits="0"/> đ
                                                </strong>
                                            </td>
                                            <td>
                                                <small class="text-muted">${transaction.note}</small>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:if>
                                <c:if test="${empty importHistory}">
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">
                                            <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                                            <p class="mt-2">Chưa có lịch sử nhập hàng</p>
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
                                    <c:url var="prevUrl" value="/provider-import">
                                        <c:param name="action" value="history"/>
                                        <c:param name="page" value="${currentPage - 1}"/>
                                        <c:param name="pageSize" value="${pageSize}"/>
                                        <c:if test="${not empty selectedProviderName}">
                                            <c:param name="providerName" value="${selectedProviderName}"/>
                                        </c:if>
                                        <c:if test="${not empty fromDate}">
                                            <c:param name="fromDate" value="${fromDate}"/>
                                        </c:if>
                                        <c:if test="${not empty toDate}">
                                            <c:param name="toDate" value="${toDate}"/>
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
                                                <c:url var="pageUrl" value="/provider-import">
                                                    <c:param name="action" value="history"/>
                                                    <c:param name="page" value="${i}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}">
                                                        <c:param name="providerName" value="${selectedProviderName}"/>
                                                    </c:if>
                                                    <c:if test="${not empty fromDate}">
                                                        <c:param name="fromDate" value="${fromDate}"/>
                                                    </c:if>
                                                    <c:if test="${not empty toDate}">
                                                        <c:param name="toDate" value="${toDate}"/>
                                                    </c:if>
                                                </c:url>
                                                <a class="page-link" href="${pageUrl}">${i}</a>
                                            </li>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <c:if test="${currentPage > 1}">
                                            <li class="page-item">
                                                <c:url var="firstUrl" value="/provider-import">
                                                    <c:param name="action" value="history"/>
                                                    <c:param name="page" value="1"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                                                    <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
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
                                                <c:url var="pageUrl" value="/provider-import">
                                                    <c:param name="action" value="history"/>
                                                    <c:param name="page" value="${i}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                                                    <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
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
                                                <c:url var="lastUrl" value="/provider-import">
                                                    <c:param name="action" value="history"/>
                                                    <c:param name="page" value="${totalPages}"/>
                                                    <c:param name="pageSize" value="${pageSize}"/>
                                                    <c:if test="${not empty selectedProviderName}"><c:param name="providerName" value="${selectedProviderName}"/></c:if>
                                                    <c:if test="${not empty fromDate}"><c:param name="fromDate" value="${fromDate}"/></c:if>
                                                    <c:if test="${not empty toDate}"><c:param name="toDate" value="${toDate}"/></c:if>
                                                </c:url>
                                                <a class="page-link" href="${lastUrl}">${totalPages}</a>
                                            </li>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                                
                                <!-- Next Button -->
                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <c:url var="nextUrl" value="/provider-import">
                                        <c:param name="action" value="history"/>
                                        <c:param name="page" value="${currentPage + 1}"/>
                                        <c:param name="pageSize" value="${pageSize}"/>
                                        <c:if test="${not empty selectedProviderName}">
                                            <c:param name="providerName" value="${selectedProviderName}"/>
                                        </c:if>
                                        <c:if test="${not empty fromDate}">
                                            <c:param name="fromDate" value="${fromDate}"/>
                                        </c:if>
                                        <c:if test="${not empty toDate}">
                                            <c:param name="toDate" value="${toDate}"/>
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
        
        <%@include file="../components/footer.jsp" %>
    </body>
</html>



