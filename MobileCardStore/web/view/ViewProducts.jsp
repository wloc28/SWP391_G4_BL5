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
        <%@include file="../components/header_v2.jsp" %>
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
                
                <!-- Filter Bar (Horizontal) -->
                <div class="bg-white border border-gray-200 rounded-xl shadow-sm mb-6">
                    <div class="px-6 py-4 bg-gradient-to-r from-gray-50 to-gray-100 rounded-t-xl border-b">
                        <div class="flex items-center gap-3">
                            <div class="p-2 bg-blue-100 rounded-lg">
                                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"></path>
                                </svg>
                            </div>
                            <div>
                                <h3 class="text-lg font-semibold text-gray-900">Bộ lọc tìm kiếm</h3>
                                <p class="text-sm text-gray-600">Tìm sản phẩm phù hợp với nhu cầu của bạn</p>
                            </div>
                        </div>
                    </div>
                    <div class="p-5">
                        <form method="GET" action="products" id="filterForm" class="space-y-4" novalidate>
                            <!-- Main Filters Row -->
                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-3">
                                <!-- Search -->
                                <div>
                                    <label for="search" class="block text-sm font-medium text-gray-700 mb-1.5">Tìm kiếm</label>
                                    <input type="text" 
                                           class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200" 
                                           id="search" name="search" value="${searchKeyword}" 
                                           placeholder="Nhập tên sản phẩm..." 
                                           maxlength="50"
                                           pattern="[a-zA-Z0-9\s]*" 
                                           title="Chỉ được nhập chữ cái, số và khoảng trắng">
                                    <div class="invalid-feedback text-red-500 text-xs mt-1 hidden">Chỉ được nhập chữ cái, số và khoảng trắng</div>
                                </div>
                                
                                <!-- Provider Filter -->
                                <div>
                                    <label for="providerId" class="block text-sm font-medium text-gray-700 mb-1.5">Nhà cung cấp</label>
                                    <select class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-white" 
                                            id="providerId" name="providerId">
                                        <option value="0">Tất cả nhà cung cấp</option>
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
                                    <label for="providerType" class="block text-sm font-medium text-gray-700 mb-1.5">Loại sản phẩm</label>
                                    <select class="w-full px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-white" 
                                            id="providerType" name="providerType">
                                        <option value="ALL" ${selectedProviderType == 'ALL' ? 'selected' : ''}>Tất cả loại</option>
                                        <option value="TEL" ${selectedProviderType == 'TEL' ? 'selected' : ''}>Thẻ điện thoại</option>
                                        <option value="GAME" ${selectedProviderType == 'GAME' ? 'selected' : ''}>Thẻ game</option>
                                    </select>
                                </div>
                                
                                <!-- Sort By -->
                                <div>
                                    <label for="sortBy" class="block text-sm font-medium text-gray-700 mb-1.5">Sắp xếp</label>
                                    <div class="flex gap-2">
                                        <select class="flex-1 px-3 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-white" 
                                                id="sortBy" name="sortBy">
                                            <option value="created_at" ${sortBy == 'created_at' ? 'selected' : ''}>Ngày tạo</option>
                                            <option value="name" ${sortBy == 'name' ? 'selected' : ''}>Tên</option>
                                            <option value="price" ${sortBy == 'price' ? 'selected' : ''}>Giá</option>
                                        </select>
                                        <select class="w-20 px-2 py-2.5 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-white" 
                                                id="sortOrder" name="sortOrder">
                                            <option value="ASC" ${sortOrder == 'ASC' ? 'selected' : ''}>↑</option>
                                            <option value="DESC" ${sortOrder == 'DESC' ? 'selected' : ''}>↓</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Price Range & Actions -->
                            <div class="flex flex-wrap items-center justify-between gap-4 pt-3 border-t border-gray-100">
                                <div class="flex-1">
                                    <label class="block text-sm font-medium text-gray-700 mb-2">Khoảng giá</label>
                                    <div class="flex flex-wrap gap-2">
                                        <c:set var="isUnder50k" value="${(empty minPrice || minPrice == '0') && (empty maxPrice || maxPrice == '50000')}" />
                                        <button type="button" onclick="setPriceRange(0, 50000)" 
                                                class="px-3 py-1.5 text-xs border rounded-full hover:bg-blue-50 hover:border-blue-300 transition-all duration-200 whitespace-nowrap ${isUnder50k ? 'bg-blue-100 border-blue-400 text-blue-800 font-medium' : 'border-gray-300 text-gray-600 hover:text-blue-600'}">
                                            < 50K
                                        </button>
                                        
                                        <c:set var="is50k100k" value="${minPrice == '50000' && maxPrice == '100000'}" />
                                        <button type="button" onclick="setPriceRange(50000, 100000)" 
                                                class="px-3 py-1.5 text-xs border rounded-full hover:bg-blue-50 hover:border-blue-300 transition-all duration-200 whitespace-nowrap ${is50k100k ? 'bg-blue-100 border-blue-400 text-blue-800 font-medium' : 'border-gray-300 text-gray-600 hover:text-blue-600'}">
                                            50K-100K
                                        </button>
                                        
                                        <c:set var="is100k200k" value="${minPrice == '100000' && maxPrice == '200000'}" />
                                        <button type="button" onclick="setPriceRange(100000, 200000)" 
                                                class="px-3 py-1.5 text-xs border rounded-full hover:bg-blue-50 hover:border-blue-300 transition-all duration-200 whitespace-nowrap ${is100k200k ? 'bg-blue-100 border-blue-400 text-blue-800 font-medium' : 'border-gray-300 text-gray-600 hover:text-blue-600'}">
                                            100K-200K
                                        </button>
                                        
                                        <c:set var="is200k500k" value="${minPrice == '200000' && maxPrice == '500000'}" />
                                        <button type="button" onclick="setPriceRange(200000, 500000)" 
                                                class="px-3 py-1.5 text-xs border rounded-full hover:bg-blue-50 hover:border-blue-300 transition-all duration-200 whitespace-nowrap ${is200k500k ? 'bg-blue-100 border-blue-400 text-blue-800 font-medium' : 'border-gray-300 text-gray-600 hover:text-blue-600'}">
                                            200K-500K
                                        </button>
                                        
                                        <c:set var="isOver500k" value="${minPrice == '500000' && empty maxPrice}" />
                                        <button type="button" onclick="setPriceRange(500000, null)" 
                                                class="px-3 py-1.5 text-xs border rounded-full hover:bg-blue-50 hover:border-blue-300 transition-all duration-200 whitespace-nowrap ${isOver500k ? 'bg-blue-100 border-blue-400 text-blue-800 font-medium' : 'border-gray-300 text-gray-600 hover:text-blue-600'}">
                                            > 500K
                                        </button>
                                        
                                        <button type="button" onclick="clearPriceRange()" 
                                                class="px-3 py-1.5 text-xs text-gray-500 hover:text-red-600 border border-gray-300 rounded-full hover:bg-red-50 hover:border-red-300 transition-all duration-200 whitespace-nowrap">
                                            ×
                                        </button>
                                    </div>
                                </div>
                                
                                <!-- Action Buttons -->
                                <div class="flex gap-2">
                                    <button type="submit" class="bg-blue-600 text-white px-4 py-2.5 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 font-medium text-sm whitespace-nowrap shadow-sm">
                                        <svg class="w-4 h-4 inline mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                                        </svg>
                                        Tìm
                                    </button>
                                    <a href="products" class="bg-gray-100 text-gray-700 px-4 py-2.5 rounded-lg hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 font-medium text-sm text-center whitespace-nowrap">
                                        <svg class="w-4 h-4 inline mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                                        </svg>
                                        Đặt lại
                                    </a>
                                </div>
                            </div>
                            
                            <!-- Hidden inputs -->
                            <input type="hidden" name="minPrice" id="minPrice" value="${minPrice}">
                            <input type="hidden" name="maxPrice" id="maxPrice" value="${maxPrice}">
                            <input type="hidden" name="pageSize" value="8">
                            <input type="hidden" name="page" value="1" id="pageInput">
                        </form>
                    </div>
                </div>
                
                <!-- Main Content Area -->
                <div class="w-full">
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
                                                <c:when test="${not empty product.providerImageUrl}">
                                                    <img src="${product.providerImageUrl}" class="w-full h-48 object-contain bg-gray-100 p-4" 
                                                         alt="${product.productName}" onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="w-full h-48 bg-gray-100 flex items-center justify-center">
                                                        <i class="bi bi-credit-card-2-front" style="font-size: 3rem; color: #6c757d;"></i>
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="p-4 flex flex-col flex-grow">
                                                <h3 class="text-base font-semibold text-gray-900 mb-2 line-clamp-2">${product.productName}</h3>
                                                <div class="flex gap-2 mb-2">
                                                    <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">${product.providerName}</span>
                                                    <c:if test="${not empty product.providerType}">
                                                        <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                                            <c:choose>
                                                                <c:when test="${product.providerType == 'TEL'}">Thẻ điện thoại</c:when>
                                                                <c:when test="${product.providerType == 'GAME'}">Thẻ game</c:when>
                                                                <c:otherwise>${product.providerType}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </c:if>
                                                </div>
                                                <p class="text-lg font-bold text-gray-900 mb-2">
                                                    <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0" /> đ
                                                </p>
                                                <div class="mb-3">
                                                    <c:choose>
                                                        <c:when test="${product.availableCount > 0}">
                                                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                                                                Còn ${product.availableCount} thẻ
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                                                                Hết hàng
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <a href="product-detail?code=${product.productCode}&providerId=${product.providerId}" class="mt-auto w-full bg-gray-900 text-white text-center px-3 py-2 rounded hover:bg-gray-800 transition-colors font-medium text-sm">
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
        
        <%@include file="../components/footer.jsp" %>
        
        <script>
            // Form validation
            (function() {
                'use strict';
                window.addEventListener('load', function() {
                    var form = document.getElementById('filterForm');
                    var searchInput = document.getElementById('search');
                    var invalidFeedback = searchInput.nextElementSibling;
                    
                    form.addEventListener('submit', function(event) {
                        var searchValue = searchInput.value.trim();
                        var isValid = true;
                        
                        // Reset validation state
                        searchInput.classList.remove('border-red-500', 'ring-2', 'ring-red-500');
                        invalidFeedback.classList.add('hidden');
                        
                        // Validate search input - only allow letters, numbers, and spaces
                        if (searchValue) {
                            // Check for invalid characters (anything except letters, numbers, and spaces)
                            if (!/^[a-zA-Z0-9\s]*$/.test(searchValue)) {
                                searchInput.classList.add('border-red-500', 'ring-2', 'ring-red-500');
                                invalidFeedback.classList.remove('hidden');
                                isValid = false;
                            }
                            // Check if it's only spaces
                            else if (searchValue.length === 0) {
                                searchInput.value = ''; // Clear empty spaces
                            }
                            // Check minimum length (at least 1 actual character)
                            else if (searchValue.replace(/\s+/g, '').length === 0) {
                                searchInput.classList.add('border-red-500', 'ring-2', 'ring-red-500');
                                invalidFeedback.textContent = 'Vui lòng nhập ít nhất một ký tự (không chỉ khoảng trắng)';
                                invalidFeedback.classList.remove('hidden');
                                isValid = false;
                            }
                        }
                        
                        if (!isValid) {
                            event.preventDefault();
                            event.stopPropagation();
                            searchInput.focus();
                        }
                    }, false);
                    
                    // Real-time validation on input
                    searchInput.addEventListener('input', function() {
                        var value = this.value;
                        // Remove invalid characters as user types
                        var cleaned = value.replace(/[^a-zA-Z0-9\s]/g, '');
                        if (value !== cleaned) {
                            this.value = cleaned;
                        }
                        
                        // Reset error state when user fixes input
                        if (this.classList.contains('border-red-500')) {
                            this.classList.remove('border-red-500', 'ring-2', 'ring-red-500');
                            invalidFeedback.classList.add('hidden');
                        }
                    });
                }, false);
            })();
            
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
