<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Quản lý Sản phẩm</title>
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
            
            /* Pagination */
            .pagination-custom .page-link {
                color: #2d2d2d;
                border-radius: 10px;
                margin: 0 4px;
                border: 1px solid #e0e0e0;
                min-width: 40px;
                text-align: center;
                font-weight: 600;
            }
            
            .pagination-custom .page-item.active .page-link {
                color: #4b2bff;
                border-color: #4b2bff;
                background: #fff;
                box-shadow: 0 0 0 2px #e7e2ff;
            }
            
            .pagination-custom .page-item.disabled .page-link {
                color: #aaa;
                background: #f0f0f0;
                border-color: #e0e0e0;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        
        <div class="container-fluid py-4">
            <div class="content-card">
                <div class="content-card-header">
                    <span><i class="bi bi-box"></i> Quản lý Sản phẩm</span>
                    <a href="${pageContext.request.contextPath}/plist?action=add" class="btn btn-primary">
                        <i class="bi bi-plus-circle"></i> Thêm sản phẩm mới
                    </a>
                </div>
                
                 <div class="content-card-body">
                     <!-- Bộ lọc tìm kiếm: chỉ hiển thị ở trang danh sách -->
                     <c:if test="${empty param.action || param.action == 'list'}">
                      <form method="get" action="${pageContext.request.contextPath}/plist" class="mb-4">
                         <div class="row g-3 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label">Tìm kiếm theo tên</label>
                                <input type="text" name="search" class="form-control" placeholder="Nhập tên sản phẩm..."
                                       value="${fn:escapeXml(searchKeyword)}">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Trạng thái</label>
                                <select name="statusFilter" class="form-select">
                                    <option value="ALL" ${statusFilter == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="ACTIVE" ${statusFilter == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                    <option value="INACTIVE" ${statusFilter == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Giá bán</label>
                                <select name="priceRange" class="form-select">
                                    <option value="ALL" ${priceRangeFilter == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                    <option value="LOW" ${priceRangeFilter == 'LOW' ? 'selected' : ''}>&lt; 100.000₫</option>
                                    <option value="MEDIUM" ${priceRangeFilter == 'MEDIUM' ? 'selected' : ''}>100.000₫ - 500.000₫</option>
                                    <option value="HIGH" ${priceRangeFilter == 'HIGH' ? 'selected' : ''}>&gt; 500.000₫</option>
                                </select>
                            </div>
                            <div class="col-md-3 d-flex gap-2 justify-content-start">
                                <button type="submit" class="btn btn-primary flex-grow-1">
                                    <i class="bi bi-search"></i> Tìm kiếm
                                </button>
                                <a href="${pageContext.request.contextPath}/plist" class="btn btn-secondary">
                                    <i class="bi bi-arrow-clockwise"></i> Reset
                                </a>
                            </div>
                         </div>
                         <!-- Sort controls -->
                          <div class="row g-3 align-items-end mt-2">
                             <div class="col-md-3">
                                 <label class="form-label">Sắp xếp theo</label>
                                 <select name="sortBy" class="form-select">
                                     <option value="CREATED" ${sortBy == 'CREATED' ? 'selected' : ''}>Ngày</option>
                                     <option value="PRICE" ${sortBy == 'PRICE' ? 'selected' : ''}>Giá</option>
                                 </select>
                             </div>
                             <div class="col-md-3">
                                 <label class="form-label">Kiểu sắp xếp</label>
                                 <select name="sortType" class="form-select">
                                     <option value="DESC" ${sortType == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                     <option value="ASC" ${sortType == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                 </select>
                             </div>
                             <div class="col-md-3 d-flex gap-2">
                                 <button type="submit" class="btn btn-outline-primary mt-1">
                                     Áp dụng
                                 </button>
                                 <button type="button" class="btn btn-outline-secondary mt-1"
                                         onclick="this.form.sortBy.value='CREATED'; this.form.sortType.value='DESC'; this.form.submit();">
                                     Reset
                                 </button>
                             </div>
                         </div>
                    </form>
                     </c:if>
                   
                    <c:if test="${not empty param.error}">
                        <div class="alert alert-danger alert-dismissible fade show" role="alert">
                            <i class="bi bi-exclamation-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.error == 'add_failed'}">Thêm sản phẩm thất bại!</c:when>
                                <c:when test="${param.error == 'update_failed'}">Cập nhật sản phẩm thất bại!</c:when>
                                <c:when test="${param.error == 'delete_failed'}">Xóa sản phẩm thất bại!</c:when>
                                <c:when test="${param.error == 'missing_description'}">Mô tả sản phẩm không được để trống!</c:when>
                                <c:when test="${param.error == 'missing_image'}">Vui lòng chọn ảnh sản phẩm!</c:when>
                                <c:when test="${param.error == 'invalid_id'}">ID không hợp lệ!</c:when>
                                <c:when test="${param.error == 'product_not_found'}">Không tìm thấy sản phẩm!</c:when>
                                <c:otherwise>${param.error}</c:otherwise>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${not empty param.success}">
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <i class="bi bi-check-circle me-2"></i>
                            <c:choose>
                                <c:when test="${param.success == 'add_success'}">Thêm sản phẩm thành công!</c:when>
                                <c:when test="${param.success == 'update_success'}">Cập nhật sản phẩm thành công!</c:when>
                                <c:when test="${param.success == 'delete_success'}">Xóa sản phẩm thành công!</c:when>
                                <c:when test="${param.success == 'hide_success'}">Ẩn sản phẩm thành công!</c:when>
                                <c:when test="${param.success == 'show_success'}">Hiện sản phẩm thành công!</c:when>
                            </c:choose>
                            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                        </div>
                    </c:if>
                    
                    <c:if test="${param.action == 'add' || param.action == 'edit'}">
                        <!-- Add/Edit Form -->
                        <form method="post" action="${pageContext.request.contextPath}/plist?action=${param.action}" enctype="multipart/form-data">
                            <input type="hidden" name="action" value="${param.action}">
                            <c:if test="${param.action == 'edit'}">
                                <input type="hidden" name="productId" value="${product.productId}">
                                <input type="hidden" name="existingImageUrl" value="${product.imageUrl}">
                            </c:if>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Nhà cung cấp <span class="text-danger">*</span></label>
                                    <select name="providerId" class="form-select" required>
                                        <option value="">-- Chọn nhà cung cấp --</option>
                                        <c:forEach var="provider" items="${providers}">
                                            <option value="${provider.providerId}" 
                                                    ${product != null && product.providerId == provider.providerId ? 'selected' : ''}>
                                                ${provider.providerName} (${provider.providerType})
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Tên sản phẩm <span class="text-danger">*</span></label>
                                    <input type="text" name="productName" class="form-control" 
                                           value="${product.productName}" required>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label class="form-label">Giá <span class="text-danger">*</span></label>
                                    <input type="number" name="price" class="form-control" 
                                           value="${product.price}" step="0.01" min="0" required>
                                </div>
                                
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái <span class="text-danger">*</span></label>
                                    <select name="status" class="form-select" required>
                                        <option value="ACTIVE" ${product != null && product.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="INACTIVE" ${product != null && product.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-12">
                                     <label class="form-label">Mô tả <span class="text-danger">*</span></label>
                                     <textarea name="description" class="form-control" rows="3" required>${product.description}</textarea>
                                </div>
                            </div>
                            
                            <div class="row mb-3">
                                <div class="col-md-12">
                                     <label class="form-label">Ảnh sản phẩm <span class="text-danger">*</span></label>
                                     <input type="file" name="avatar" class="form-control" accept=".jpg,.jpeg,.png"
                                            <c:if test="${param.action == 'add'}">required</c:if>>
                                    <c:if test="${param.action == 'edit' && not empty product.imageUrl}">
                                        <div class="form-text">Ảnh hiện tại: ${product.imageUrl}</div>
                                    </c:if>
                                    <div class="form-text">Hỗ trợ định dạng .jpg, .jpeg, .png</div>
                                </div>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-save"></i> Lưu
                                </button>
                                <a href="${pageContext.request.contextPath}/plist" class="btn btn-secondary">
                                    <i class="bi bi-x-circle"></i> Hủy
                                </a>
                            </div>
                        </form>
                    </c:if>
                    
                    <c:if test="${empty param.action || param.action == 'list'}">
                        <!-- Product List -->
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Hình ảnh</th>
                                        <th>Nhà cung cấp</th>
                                        <th>Tên sản phẩm</th>
                                        <th>Giá</th>
                                        <th>Trạng thái</th>
                                        <th>Ngày tạo</th>
                                        <th>Hành động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:if test="${not empty products}">
                                        <c:forEach var="product" items="${products}">
                                            <tr>
                                                <td>${product.productId}</td>
                                                <td style="width: 90px;">
                                                    <c:choose>
                                                        <c:when test="${not empty product.imageUrl}">
                                                            <img src="${pageContext.request.contextPath}/${product.imageUrl}" alt="${product.productName}" style="width:70px;height:70px;object-fit:cover;border-radius:6px;border:1px solid #eee;">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-muted fst-italic">Chưa có</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${not empty product.provider}">
                                                            ${product.provider.providerName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            Provider #${product.providerId}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td><strong>${product.productName}</strong></td>
                                                <td>
                                                    <fmt:formatNumber value="${product.price}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${product.status == 'ACTIVE'}">
                                                            <span class="status-badge status-active">${product.status}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-inactive">${product.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <fmt:formatDate value="${product.createdAt}" pattern="dd/MM/yyyy" />
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/plist?action=edit&id=${product.productId}" class="btn btn-sm btn-warning btn-action">
                                                        <i class="bi bi-pencil"></i> Sửa
                                                    </a>
                                                    <a href="${pageContext.request.contextPath}/plist?action=delete&id=${product.productId}" 
                                                       class="btn btn-sm btn-danger btn-action"
                                                       onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">
                                                        <i class="bi bi-trash"></i> Xóa
                                                    </a>
                                                    <c:choose>
                                                        <c:when test="${product.status == 'ACTIVE'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/plist?action=toggleStatus" style="display:inline;">
                                                                <input type="hidden" name="id" value="${product.productId}">
                                                                <input type="hidden" name="status" value="INACTIVE">
                                                                <button type="submit" class="btn btn-sm btn-outline-secondary btn-action"
                                                                        onclick="return confirm('Bạn có chắc chắn muốn ẩn sản phẩm này?');">
                                                                    <i class="bi bi-eye-slash"></i> Ẩn
                                                                </button>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <form method="post" action="${pageContext.request.contextPath}/plist?action=toggleStatus" style="display:inline;">
                                                                <input type="hidden" name="id" value="${product.productId}">
                                                                <input type="hidden" name="status" value="ACTIVE">
                                                                <button type="submit" class="btn btn-sm btn-outline-success btn-action">
                                                                    <i class="bi bi-eye"></i> Hiện
                                                                </button>
                                                            </form>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:if>
                                    <c:if test="${empty products}">
                                        <tr>
                                            <td colspan="7" class="text-center text-muted py-4">
                                                <i class="bi bi-inbox" style="font-size: 2rem;"></i>
                                                <p class="mt-2">Chưa có sản phẩm nào</p>
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                        <c:if test="${totalPages > 1}">
                            <nav aria-label="Pagination" class="mt-3 d-flex justify-content-center">
                                <ul class="pagination pagination-sm pagination-custom mb-0">
                                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/plist?page=${currentPage - 1}" aria-label="Previous">
                                            &lsaquo;
                                        </a>
                                    </li>
                                    <c:forEach var="p" begin="1" end="${totalPages}">
                                        <li class="page-item ${p == currentPage ? 'active' : ''}">
                                            <a class="page-link" href="${pageContext.request.contextPath}/plist?page=${p}">${p}</a>
                                        </li>
                                    </c:forEach>
                                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                        <a class="page-link" href="${pageContext.request.contextPath}/plist?page=${currentPage + 1}" aria-label="Next">
                                            &rsaquo;
                                        </a>
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

