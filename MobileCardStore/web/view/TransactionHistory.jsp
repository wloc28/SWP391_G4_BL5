<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lịch sử giao dịch</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .balance-card {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border-radius: 10px;
                padding: 20px;
                margin-bottom: 20px;
            }
            .transaction-type {
                padding: 4px 12px;
                border-radius: 4px;
                font-size: 12px;
                font-weight: bold;
            }
            .type-DEPOSIT {
                background-color: #28a745;
                color: white;
            }
            .type-PAYMENT {
                background-color: #dc3545;
                color: white;
            }
            .type-REFUND {
                background-color: #ffc107;
                color: #000;
            }
            .status-badge {
                padding: 4px 12px;
                border-radius: 4px;
                font-size: 12px;
            }
            .status-SUCCESS {
                background-color: #d4edda;
                color: #155724;
            }
            .status-PENDING {
                background-color: #fff3cd;
                color: #856404;
            }
            .status-FAILED {
                background-color: #f8d7da;
                color: #721c24;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container py-4">
            <h2 class="mb-4">Lịch sử giao dịch</h2>
            
            <!-- Balance Card -->
            <div class="balance-card">
                <h5 class="mb-2">Số dư ví hiện tại</h5>
                <h2 class="mb-0">
                    <fmt:formatNumber value="${currentBalance}" type="number" 
                                      maxFractionDigits="0" pattern="#,###"/> VND
                </h2>
            </div>
            
            <!-- Summary Cards -->
            <div class="row mb-4">
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="text-muted">Tổng nạp tiền</h6>
                            <h4 class="text-success">
                                <fmt:formatNumber value="${totalDeposit}" type="number" 
                                                  maxFractionDigits="0" pattern="#,###"/> VND
                            </h4>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-body">
                            <h6 class="text-muted">Tổng chi tiêu</h6>
                            <h4 class="text-danger">
                                <fmt:formatNumber value="${totalPayment}" type="number" 
                                                  maxFractionDigits="0" pattern="#,###"/> VND
                            </h4>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Filter Form -->
            <div class="card mb-4">
                <div class="card-body">
                    <form method="GET" action="${pageContext.request.contextPath}/transaction-history" onsubmit="document.getElementById('pageInput').value='1'">
                        <input type="hidden" name="page" value="1" id="pageInput">
                        <div class="row">
                            <div class="col-md-3">
                                <label>Loại giao dịch</label>
                                <select name="type" class="form-control">
                                    <option value="">Tất cả</option>
                                    <option value="DEPOSIT" ${selectedType == 'DEPOSIT' ? 'selected' : ''}>
                                        Nạp tiền
                                    </option>
                                    <option value="PAYMENT" ${selectedType == 'PAYMENT' ? 'selected' : ''}>
                                        Thanh toán
                                    </option>
                                    <option value="REFUND" ${selectedType == 'REFUND' ? 'selected' : ''}>
                                        Hoàn tiền
                                    </option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label>Từ ngày</label>
                                <input type="date" name="fromDate" class="form-control" 
                                       value="${fromDate}">
                            </div>
                            <div class="col-md-2">
                                <label>Đến ngày</label>
                                <input type="date" name="toDate" class="form-control" 
                                       value="${toDate}">
                            </div>
                            <div class="col-md-2">
                                <label>Số lượng/trang</label>
                                <select name="pageSize" class="form-control" id="pageSizeSelect" onchange="this.form.submit()">
                                    <option value="5" ${selectedPageSize == '5' || empty selectedPageSize ? 'selected' : ''}>5</option>
                                    <option value="10" ${selectedPageSize == '10' ? 'selected' : ''}>10</option>
                                    <option value="15" ${selectedPageSize == '15' ? 'selected' : ''}>15</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label>&nbsp;</label><br>
                                <button type="submit" class="btn btn-primary">Lọc</button>
                                <a href="${pageContext.request.contextPath}/transaction-history" 
                                   class="btn btn-secondary">Reset</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
            
            <!-- Transactions Table -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">Danh sách giao dịch</h5>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${empty transactions}">
                            <p class="text-muted text-center py-4">Chưa có giao dịch nào</p>
                        </c:when>
                        <c:otherwise>
                            <div class="table-responsive">
                                <table class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th>STT</th>
                                            <th>Thời gian</th>
                                            <th>Loại</th>
                                            <th>Số tiền</th>
                                            <th>Mô tả</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="t" items="${transactions}" varStatus="status">
                                            <tr>
                                                <td>${(currentPage - 1) * pageSize + status.index + 1}</td>
                                                <td>
                                                    <fmt:formatDate value="${t.createdAt}" 
                                                                    pattern="dd/MM/yyyy HH:mm:ss"/>
                                                </td>
                                                <td>
                                                    <span class="transaction-type type-${t.transactionType}">
                                                        <c:choose>
                                                            <c:when test="${t.transactionType == 'DEPOSIT'}">
                                                                Nạp tiền
                                                            </c:when>
                                                            <c:when test="${t.transactionType == 'PAYMENT'}">
                                                                Thanh toán
                                                            </c:when>
                                                            <c:when test="${t.transactionType == 'REFUND'}">
                                                                Hoàn tiền
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${t.transactionType == 'DEPOSIT' || t.transactionType == 'REFUND'}">
                                                            <span class="text-success">
                                                                +<fmt:formatNumber value="${t.amount}" 
                                                                                  type="number" 
                                                                                  maxFractionDigits="0" 
                                                                                  pattern="#,###"/> đ
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-danger">
                                                                -<fmt:formatNumber value="${t.amount}" 
                                                                                  type="number" 
                                                                                  maxFractionDigits="0" 
                                                                                  pattern="#,###"/> đ
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>${t.description != null ? t.description : '-'}</td>
                                                <td>
                                                    <span class="status-badge status-${t.status}">
                                                        <c:choose>
                                                            <c:when test="${t.status == 'SUCCESS'}">
                                                                Thành công
                                                            </c:when>
                                                            <c:when test="${t.status == 'PENDING'}">
                                                                Đang xử lý
                                                            </c:when>
                                                            <c:when test="${t.status == 'FAILED'}">
                                                                Thất bại
                                                            </c:when>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <!-- Pagination -->
            <c:if test="${totalPages > 1}">
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <!-- Previous Button -->
                        <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                            <c:url var="prevUrl" value="/transaction-history">
                                <c:param name="page" value="${currentPage - 1}"/>
                                <c:param name="pageSize" value="${pageSize}"/>
                                <c:if test="${not empty selectedType}">
                                    <c:param name="type" value="${selectedType}"/>
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
                                        <c:url var="pageUrl" value="/transaction-history">
                                            <c:param name="page" value="${i}"/>
                                            <c:param name="pageSize" value="${pageSize}"/>
                                            <c:if test="${not empty selectedType}">
                                                <c:param name="type" value="${selectedType}"/>
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
                                        <c:url var="firstUrl" value="/transaction-history">
                                            <c:param name="page" value="1"/>
                                            <c:param name="pageSize" value="${pageSize}"/>
                                            <c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}"/></c:if>
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
                                        <c:url var="pageUrl" value="/transaction-history">
                                            <c:param name="page" value="${i}"/>
                                            <c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}"/></c:if>
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
                                        <c:url var="lastUrl" value="/transaction-history">
                                            <c:param name="page" value="${totalPages}"/>
                                            <c:param name="pageSize" value="${pageSize}"/>
                                            <c:if test="${not empty selectedType}"><c:param name="type" value="${selectedType}"/></c:if>
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
                            <c:url var="nextUrl" value="/transaction-history">
                                <c:param name="page" value="${currentPage + 1}"/>
                                <c:param name="pageSize" value="${pageSize}"/>
                                <c:if test="${not empty selectedType}">
                                    <c:param name="type" value="${selectedType}"/>
                                </c:if>
                                <c:if test="${not empty fromDate}">
                                    <c:param name="fromDate" value="${fromDate}"/>
                                </c:if>
                                <c:if test="${not empty toDate}">
                                    <c:param name="toDate" value="${toDate}"/>
                                </c:if>
                            </c:url>
                            <a class="page-link" href="${nextUrl}" ${currentPage == totalPages ? 'tabindex="-1" aria-disabled="true"' : ''}>
                                Tiếp <i class="bi bi-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
                
                <!-- Pagination Info -->
                <div class="text-center text-muted mt-2">
                    Hiển thị ${startItem} - ${endItem} trong tổng số ${totalCount} giao dịch
                </div>
            </c:if>
        </div>
        <%@include file="../components/footer.jsp" %>
    </body>
</html>
