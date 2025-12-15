<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Danh Sách Sản Phẩm</title>
        <%@include file="../components/libs.jsp" %>
        <script src="https://cdn.tailwindcss.com"></script>
        <style>
            /* Professional minimal styles */
        </style>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        <div class="w-full px-4 py-6">
            <div class="max-w-[1600px] mx-auto">
                <h1 class="text-2xl font-semibold text-gray-900 mb-6">Danh Sách Sản Phẩm</h1>
            
                <!-- Error/Success Messages -->
                <c:if test="${not empty error}">
                    <div class="bg-red-50 border border-red-200 rounded-lg p-3 mb-4">
                        <div class="flex justify-between items-center">
                            <p class="text-red-800 text-sm">${error}</p>
                            <button type="button" onclick="this.parentElement.parentElement.remove()" class="text-red-600 hover:text-red-800">
                                <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </c:if>
                
                <!-- Main Layout: Sidebar + Content -->
                <div class="flex flex-col lg:flex-row gap-6">
                    <!-- Sidebar Filter -->
                    <aside class="lg:w-64 flex-shrink-0">
                        <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-4 sticky top-4">
                            <h2 class="text-sm font-semibold text-gray-900 mb-4">Bộ lọc</h2>
                            <form method="GET" action="products" id="filterForm" class="space-y-4">
                                <!-- Search -->
                                <div>
                                    <label for="search" class="block text-xs font-medium text-gray-700 mb-1">Tìm kiếm</label>
                                    <input type="text" 
                                           class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-500 transition-colors" 
                                           id="search" name="search" value="${searchKeyword}" placeholder="Tên sản phẩm...">
                                </div>
                                
                                <!-- Provider Filter -->
                                <div>
                                    <label for="providerId" class="block text-xs font-medium text-gray-700 mb-1">Nhà cung cấp</label>
                                    <select class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-500 transition-colors bg-white" 
                                            id="providerId" name="providerId">
                                        <option value="0">Tất cả</option>
                                        <c:if test="${providers != null}">
                                            <c:forEach var="provider" items="${providers}">
                                                <option value="${provider.providerId}" 
                                                        ${selectedProviderId == provider.providerId ? 'selected' : ''}>
                                                    ${provider.providerName}
                                                </option>
                                            </c:forEach>
                                        </c:if>
                                    </select>
                                </div>
                                
                                <!-- Provider Type Filter -->
                                <div>
                                    <label for="providerType" class="block text-xs font-medium text-gray-700 mb-1">Loại</label>
                                    <select class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-500 transition-colors bg-white" 
                                            id="providerType" name="providerType">
                                        <option value="ALL" ${selectedProviderType == 'ALL' ? 'selected' : ''}>Tất cả</option>
                                        <option value="TEL" ${selectedProviderType == 'TEL' ? 'selected' : ''}>Điện thoại</option>
                                        <option value="GAME" ${selectedProviderType == 'GAME' ? 'selected' : ''}>Game</option>
                                    </select>
                                </div>
                                
                                <!-- Price Range -->
                                <div>
                                    <label class="block text-xs font-medium text-gray-700 mb-2">Khoảng giá</label>
                                    <div class="space-y-2">
                                        <c:set var="isUnder50k" value="${(empty minPrice || minPrice == '0') && (empty maxPrice || maxPrice == '50000')}" />
                                        <button type="button" onclick="setPriceRange(0, 50000)" 
                                                class="w-full text-left px-3 py-2 text-sm border border-gray-300 rounded hover:bg-gray-50 transition-colors ${isUnder50k ? 'bg-gray-100 border-gray-400 font-medium' : ''}">
                                            Dưới 50.000 đ
                                        </button>
                                        
                                        <c:set var="is50k100k" value="${minPrice == '50000' && maxPrice == '100000'}" />
                                        <button type="button" onclick="setPriceRange(50000, 100000)" 
                                                class="w-full text-left px-3 py-2 text-sm border border-gray-300 rounded hover:bg-gray-50 transition-colors ${is50k100k ? 'bg-gray-100 border-gray-400 font-medium' : ''}">
                                            50.000 - 100.000 đ
                                        </button>
                                        
                                        <c:set var="is100k200k" value="${minPrice == '100000' && maxPrice == '200000'}" />
                                        <button type="button" onclick="setPriceRange(100000, 200000)" 
                                                class="w-full text-left px-3 py-2 text-sm border border-gray-300 rounded hover:bg-gray-50 transition-colors ${is100k200k ? 'bg-gray-100 border-gray-400 font-medium' : ''}">
                                            100.000 - 200.000 đ
                                        </button>
                                        
                                        <c:set var="is200k500k" value="${minPrice == '200000' && maxPrice == '500000'}" />
                                        <button type="button" onclick="setPriceRange(200000, 500000)" 
                                                class="w-full text-left px-3 py-2 text-sm border border-gray-300 rounded hover:bg-gray-50 transition-colors ${is200k500k ? 'bg-gray-100 border-gray-400 font-medium' : ''}">
                                            200.000 - 500.000 đ
                                        </button>
                                        
                                        <c:set var="isOver500k" value="${minPrice == '500000' && empty maxPrice}" />
                                        <button type="button" onclick="setPriceRange(500000, null)" 
                                                class="w-full text-left px-3 py-2 text-sm border border-gray-300 rounded hover:bg-gray-50 transition-colors ${isOver500k ? 'bg-gray-100 border-gray-400 font-medium' : ''}">
                                            Trên 500.000 đ
                                        </button>
                                        
                                        <button type="button" onclick="clearPriceRange()" 
                                                class="w-full text-left px-3 py-2 text-sm text-gray-600 hover:text-gray-900 transition-colors">
                                            Tất cả giá
                                        </button>
                                    </div>
                                    <!-- Hidden inputs for price range -->
                                    <input type="hidden" name="minPrice" id="minPrice" value="${minPrice}">
                                    <input type="hidden" name="maxPrice" id="maxPrice" value="${maxPrice}">
                                </div>
                                
                                <!-- Sort By -->
                                <div>
                                    <label for="sortBy" class="block text-xs font-medium text-gray-700 mb-1">Sắp xếp theo</label>
                                    <select class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-500 transition-colors bg-white" 
                                            id="sortBy" name="sortBy">
                                        <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Mới nhất</option>
                                        <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Tên A-Z</option>
                                        <option value="price" ${sortBy == 'price' ? 'selected' : ''}>Giá</option>
                                    </select>
                                </div>
                                
                                <!-- Sort Order -->
                                <div>
                                    <label for="sortOrder" class="block text-xs font-medium text-gray-700 mb-1">Thứ tự</label>
                                    <select class="w-full px-3 py-2 border border-gray-300 rounded text-sm focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-500 transition-colors bg-white" 
                                            id="sortOrder" name="sortOrder">
                                        <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>Tăng dần</option>
                                        <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>Giảm dần</option>
                                    </select>
                                </div>
                                
                                <!-- Action Buttons -->
                                <div class="flex gap-2 pt-2">
                                    <button type="submit" class="flex-1 bg-gray-900 text-white px-4 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                        Tìm kiếm
                                    </button>
                                    <a href="products" class="flex-1 bg-white text-gray-700 border border-gray-300 px-4 py-2 rounded hover:bg-gray-50 transition-colors font-medium text-sm text-center">
                                        Reset
                                    </a>
                                </div>
                                
                                <!-- Hidden fields -->
                                <input type="hidden" name="pageSize" value="12">
                                <input type="hidden" name="page" value="1" id="pageInput">
                            </form>
                        </div>
                    </aside>
                    
                    <!-- Main Content Area -->
                    <div class="flex-1 min-w-0">
                        <!-- Results Info -->
                        <div class="flex justify-between items-center mb-4">
                            <p class="text-sm text-gray-600">
                                Hiển thị <span class="font-semibold text-gray-900">${products != null ? products.size() : 0}</span> trong tổng số <span class="font-semibold text-gray-900">${totalCount != null ? totalCount : 0}</span> sản phẩm
                            </p>
                        </div>
                        
                        <!-- Products Grid -->
                        <c:choose>
                            <c:when test="${empty products}">
                                <div class="bg-blue-50 border border-blue-200 rounded-lg p-8 text-center">
                                    <h5 class="text-lg font-medium text-gray-900 mb-2">Không tìm thấy sản phẩm nào</h5>
                                    <p class="text-gray-600">Vui lòng thử lại với bộ lọc khác</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                                    <c:forEach var="product" items="${products}">
                                        <div class="bg-white border border-gray-200 rounded-lg shadow-sm hover:shadow-md transition-shadow overflow-hidden flex flex-col">
                                            <c:choose>
                                                <c:when test="${not empty product.imageUrl}">
                                                    <img src="${product.imageUrl}" class="w-full h-48 object-cover bg-gray-100" 
                                                         alt="${product.productName}" onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="https://via.placeholder.com/300x200?text=No+Image" 
                                                         class="w-full h-48 object-cover bg-gray-100" alt="${product.productName}">
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="p-4 flex flex-col flex-grow">
                                                <h3 class="text-base font-semibold text-gray-900 mb-2 line-clamp-2">${product.productName}</h3>
                                                <div class="flex gap-2 mb-2">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">${product.provider.providerName}</span>
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">${product.provider.providerType}</span>
                                                </div>
                                                <p class="text-lg font-bold text-gray-900 mb-3">
                                                    <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0" /> đ
                                                </p>
                                                <c:if test="${not empty product.description}">
                                                    <p class="text-xs text-gray-600 mb-3 flex-grow line-clamp-2">
                                                        ${product.description.length() > 100 ? product.description.substring(0, 100) + '...' : product.description}
                                                    </p>
                                                </c:if>
                                                <a href="product-detail?id=${product.productId}" class="mt-auto w-full bg-gray-900 text-white text-center px-3 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
                                                    Xem chi tiết
                                                </a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                
                                <!-- Pagination -->
                                <c:if test="${totalPages != null && totalPages > 1}">
                                    <nav aria-label="Page navigation" class="mt-6">
                                        <ul class="flex justify-center items-center gap-2">
                                            <!-- Previous Button -->
                                            <li>
                                                <a class="px-3 py-2 border border-gray-300 rounded ${currentPage == 1 ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white text-gray-700 hover:bg-gray-50'}" 
                                                   href="javascript:void(0)" onclick="goToPage(${currentPage - 1})" ${currentPage == 1 ? 'onclick="return false;"' : ''}>
                                                    Trước
                                                </a>
                                            </li>
                                            
                                            <!-- Page Numbers -->
                                            <c:forEach var="i" begin="1" end="${totalPages}">
                                                <c:choose>
                                                    <c:when test="${i == currentPage}">
                                                        <li>
                                                            <span class="px-4 py-2 bg-gray-900 text-white rounded font-medium">${i}</span>
                                                        </li>
                                                    </c:when>
                                                    <c:when test="${i <= 3 || i > totalPages - 3 || (i >= currentPage - 1 && i <= currentPage + 1)}">
                                                        <li>
                                                            <a class="px-4 py-2 border border-gray-300 rounded bg-white text-gray-700 hover:bg-gray-50" 
                                                               href="javascript:void(0)" onclick="goToPage(${i})">${i}</a>
                                                        </li>
                                                    </c:when>
                                                    <c:when test="${i == 4 && currentPage > 5}">
                                                        <li>
                                                            <span class="px-2 py-2 text-gray-400">...</span>
                                                        </li>
                                                    </c:when>
                                                    <c:when test="${i == totalPages - 3 && currentPage < totalPages - 4}">
                                                        <li>
                                                            <span class="px-2 py-2 text-gray-400">...</span>
                                                        </li>
                                                    </c:when>
                                                </c:choose>
                                            </c:forEach>
                                            
                                            <!-- Next Button -->
                                            <li>
                                                <a class="px-3 py-2 border border-gray-300 rounded ${currentPage == totalPages ? 'bg-gray-100 text-gray-400 cursor-not-allowed' : 'bg-white text-gray-700 hover:bg-gray-50'}" 
                                                   href="javascript:void(0)" onclick="goToPage(${currentPage + 1})" ${currentPage == totalPages ? 'onclick="return false;"' : ''}>
                                                    Sau
                                                </a>
                                            </li>
                                        </ul>
                                    </nav>
                                </c:if>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            function goToPage(page) {
                var totalPages = ${totalPages != null ? totalPages : 1};
                if (page < 1 || page > totalPages) return;
                document.getElementById('pageInput').value = page;
                document.getElementById('filterForm').submit();
            }
            
            function setPriceRange(min, max) {
                document.getElementById('minPrice').value = min || '';
                document.getElementById('maxPrice').value = max || '';
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            }
            
            function clearPriceRange() {
                document.getElementById('minPrice').value = '';
                document.getElementById('maxPrice').value = '';
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            }
            
            // Auto-submit on filter change
            document.getElementById('sortBy').addEventListener('change', function() {
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            });
            
            document.getElementById('sortOrder').addEventListener('change', function() {
                document.getElementById('pageInput').value = 1;
                document.getElementById('filterForm').submit();
            });
        </script>
    </body>
</html>
