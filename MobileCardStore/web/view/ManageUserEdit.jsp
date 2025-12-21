<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Chỉnh sửa người dùng</title>
        <%@include file="../components/libs.jsp" %>
        <style>
            .form-control:read-only {
                background-color: #e9ecef;
                cursor: not-allowed;
            }
            
            .is-valid {
                border-color: #198754;
            }
            
            .is-invalid {
                border-color: #dc3545;
            }
            
            #passwordMatchError {
                display: none;
            }
            
            .form-control.is-invalid-custom {
                border-color: #dc3545;
                box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
            }
            
            .form-control.is-valid-custom {
                border-color: #198754;
                box-shadow: 0 0 0 0.2rem rgba(25, 135, 84, 0.25);
            }
            
            #fullNameErrorMsg,
            #phoneNumberErrorMsg,
            #newPasswordErrorMsg,
            #confirmPasswordErrorMsg,
            #balanceErrorMsg {
                font-size: 0.75rem;
            }
        </style>
    </head>
    <body>
        <%@include file="../components/header_v2.jsp" %>
        <div class="container py-4">
            <h2 class="mb-3">Chỉnh sửa người dùng</h2>

            <c:if test="${not empty param.error}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="bi bi-exclamation-circle me-2"></i>
                    <c:choose>
                        <c:when test="${param.error == 'update_failed'}">Cập nhật người dùng thất bại!</c:when>
                        <c:when test="${param.error == 'invalid_id'}">ID không hợp lệ!</c:when>
                        <c:when test="${param.error == 'user_not_found'}">Không tìm thấy người dùng!</c:when>
                        <c:when test="${param.error == 'password_mismatch'}">Mật khẩu nhập lại không khớp!</c:when>
                        <c:when test="${param.error == 'password_too_short'}">Mật khẩu phải có ít nhất 6 ký tự!</c:when>
                        <c:otherwise>${param.error}</c:otherwise>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty param.success}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle me-2"></i>
                    <c:choose>
                        <c:when test="${param.success == 'update_success'}">Cập nhật người dùng thành công!</c:when>
                    </c:choose>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty user}">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <form method="post" action="${pageContext.request.contextPath}/admin/user-edit" novalidate>
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="userId" value="${user.userId}">

                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Tên đăng nhập</label>
                                    <input type="text" class="form-control" value="${user.username}" 
                                           readonly style="background-color: #e9ecef; cursor: not-allowed;">
                                    <input type="hidden" name="username" value="${user.username}">
                                    <small class="text-muted">Tên đăng nhập không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Email</label>
                                    <input type="email" class="form-control" value="${user.email}" 
                                           readonly style="background-color: #e9ecef; cursor: not-allowed;">
                                    <input type="hidden" name="email" value="${user.email}">
                                    <small class="text-muted">Email không thể thay đổi</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Họ tên</label>
                                    <input type="text" class="form-control" name="fullName" id="fullName" value="${user.fullName}" maxlength="100">
                                    <div class="invalid-feedback" id="fullNameError">Họ tên không được vượt quá 100 ký tự</div>
                                    <div class="text-danger small mt-1" id="fullNameErrorMsg" style="display: none;"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số điện thoại</label>
                                    <input type="tel" class="form-control" name="phoneNumber" id="phoneNumber" value="${user.phoneNumber}" 
                                           pattern="[0-9]{10,15}" maxlength="15">
                                    <div class="invalid-feedback">Số điện thoại phải có 10-15 chữ số</div>
                                    <div class="text-danger small mt-1" id="phoneNumberErrorMsg" style="display: none;"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Vai trò</label>
                                    <select class="form-select" name="role" required>
                                        <option value="CUSTOMER" ${user.role == 'CUSTOMER' ? 'selected' : ''}>CUSTOMER</option>
                                        <option value="ADMIN" ${user.role == 'ADMIN' ? 'selected' : ''}>ADMIN</option>
                                    </select>
                                    <div class="invalid-feedback">Vui lòng chọn vai trò</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Trạng thái</label>
                                    <select class="form-select" name="status" required
                                            ${(sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId) ? 'disabled' : ''}>
                                        <option value="ACTIVE" ${user.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                        <option value="BANNED" ${user.status == 'BANNED' ? 'selected' : ''}>BANNED</option>
                                    </select>
                                    <c:if test="${sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId}">
                                        <input type="hidden" name="status" value="${user.status}">
                                        <small class="text-muted">Bạn không thể chỉnh sửa trạng thái của chính mình</small>
                                    </c:if>
                                    <div class="invalid-feedback">Vui lòng chọn trạng thái</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Mật khẩu mới (để trống nếu không đổi)</label>
                                    <input type="password" class="form-control" name="newPassword" id="newPassword"
                                           placeholder="Nhập mật khẩu mới..." minlength="6" maxlength="100">
                                    <div class="invalid-feedback">Mật khẩu phải có ít nhất 6 ký tự</div>
                                    <div class="text-danger small mt-1" id="newPasswordErrorMsg" style="display: none;"></div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Nhập lại mật khẩu mới</label>
                                    <input type="password" class="form-control" name="confirmPassword" id="confirmPassword"
                                           placeholder="Nhập lại mật khẩu mới..." minlength="6" maxlength="100">
                                    <div class="invalid-feedback" id="passwordMatchError">Mật khẩu nhập lại không khớp</div>
                                    <div class="text-danger small mt-1" id="confirmPasswordErrorMsg" style="display: none;"></div>
                                    <small class="text-muted">Chỉ cần nhập khi thay đổi mật khẩu</small>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số dư</label>

                                    <!-- Input hiển thị (format VND) -->
                                    <input type="text"
                                           class="form-control"
                                           id="balanceDisplay"
                                           value="<fmt:formatNumber value='${user.balance}' type='number' groupingUsed='true'/>"
                                           ${(sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId) ? '' : 'readonly'}
                                           placeholder="0 ₫">

                                    <!-- Input thật gửi về server -->
                                    <input type="hidden"
                                           name="balance"
                                           id="balance"
                                           value="${user.balance}">

                                    <div class="text-danger small mt-1" id="balanceErrorMsg" style="display: none;"></div>
                                    <c:choose>
                                        <c:when test="${sessionScope.user.role == 'ADMIN' && sessionScope.user.userId == user.userId}">
                                            <small class="text-muted">Bạn có thể chỉnh sửa số dư của chính mình (VND)</small>
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-muted">Số dư chỉ có thể thay đổi thông qua giao dịch</small>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                
                            </div>

                            <hr class="my-4">

                            <div class="d-flex gap-3 flex-wrap">
                                <button type="submit" class="btn btn-primary">
                                    <i class="bi bi-check-lg"></i> Lưu thay đổi
                                </button>
                                <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-secondary">
                                    <i class="bi bi-arrow-left"></i> Quay lại danh sách
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </c:if>
        </div>

        <%@include file="../components/footer.jsp" %>

        <!-- Form validation script -->
        <script>
            (function () {
                'use strict';
                window.addEventListener('load', function () {
                    var forms = document.getElementsByTagName('form');
                    var form = forms[0];
                    if (!form) return;
                    
                    var newPasswordInput = document.getElementById('newPassword');
                    var confirmPasswordInput = document.getElementById('confirmPassword');
                    var passwordMatchError = document.getElementById('passwordMatchError');
                    var formValidated = false;
                        
                    // Password match validation - only show errors after form submission
                    function validatePasswordMatch(showErrors) {
                        if (!newPasswordInput || !confirmPasswordInput) return true;
                        
                        var newPassword = newPasswordInput.value.trim();
                        var confirmPassword = confirmPasswordInput.value.trim();
                        
                        // Reset validation state
                        confirmPasswordInput.classList.remove('is-invalid', 'is-valid');
                        if (passwordMatchError) passwordMatchError.style.display = 'none';
                        
                        // If new password is provided, confirm password must match
                        if (newPassword.length > 0) {
                            if (confirmPassword.length === 0) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Vui lòng nhập lại mật khẩu mới';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            } else if (newPassword !== confirmPassword) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Mật khẩu nhập lại không khớp';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            } else {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-valid');
                                }
                                return true;
                            }
                        } else {
                            // If new password is empty, confirm password should also be empty
                            if (confirmPassword.length > 0) {
                                if (showErrors) {
                                    confirmPasswordInput.classList.add('is-invalid');
                                    if (passwordMatchError) {
                                        passwordMatchError.textContent = 'Vui lòng nhập mật khẩu mới trước';
                                        passwordMatchError.style.display = 'block';
                                    }
                                }
                                return false;
                            }
                            return true;
                        }
                    }
                    
                    // Real-time validation - only show visual feedback after form has been submitted
                    if (newPasswordInput && confirmPasswordInput) {
                        newPasswordInput.addEventListener('input', function() {
                            if (formValidated) {
                                validatePasswordMatch(true);
                            }
                        });
                        
                        confirmPasswordInput.addEventListener('input', function() {
                            if (formValidated) {
                                validatePasswordMatch(true);
                            }
                        });
                    }
                    
                    // Validation functions for other fields
                    function validateFullName(showErrors) {
                        var fullNameInput = document.getElementById('fullName');
                        var errorMsg = document.getElementById('fullNameErrorMsg');
                        
                        if (!fullNameInput || !errorMsg) return true;
                        
                        var value = fullNameInput.value.trim();
                        
                        // Reset validation state
                        fullNameInput.classList.remove('is-invalid-custom', 'is-valid-custom');
                        errorMsg.style.display = 'none';
                        errorMsg.textContent = '';
                        
                        // If empty, no validation needed (optional field)
                        if (!value) {
                            return true;
                        }
                        
                        // Check if only spaces
                        if (value.replace(/\s+/g, '').length === 0) {
                            if (showErrors) {
                                fullNameInput.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Họ tên không được chỉ chứa khoảng trắng';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Check max length
                        if (value.length > 100) {
                            if (showErrors) {
                                fullNameInput.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Họ tên không được vượt quá 100 ký tự';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Valid
                        if (showErrors && value) {
                            fullNameInput.classList.add('is-valid-custom');
                        }
                        return true;
                    }
                    
                    function validatePhoneNumber(showErrors) {
                        var phoneInput = document.getElementById('phoneNumber');
                        var errorMsg = document.getElementById('phoneNumberErrorMsg');
                        
                        if (!phoneInput || !errorMsg) return true;
                        
                        var value = phoneInput.value.trim();
                        
                        // Reset validation state
                        phoneInput.classList.remove('is-invalid-custom', 'is-valid-custom');
                        errorMsg.style.display = 'none';
                        errorMsg.textContent = '';
                        
                        // If empty, no validation needed (optional field)
                        if (!value) {
                            return true;
                        }
                        
                        // Check if only digits
                        if (!/^[0-9]+$/.test(value)) {
                            if (showErrors) {
                                phoneInput.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Số điện thoại chỉ được chứa chữ số';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Check length
                        if (value.length < 10 || value.length > 15) {
                            if (showErrors) {
                                phoneInput.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Số điện thoại phải có 10-15 chữ số';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Valid
                        if (showErrors && value) {
                            phoneInput.classList.add('is-valid-custom');
                        }
                        return true;
                    }
                    
                    function validateNewPassword(showErrors) {
                        var passwordInput = document.getElementById('newPassword');
                        var errorMsg = document.getElementById('newPasswordErrorMsg');
                        
                        if (!passwordInput || !errorMsg) return true;
                        
                        var value = passwordInput.value.trim();
                        
                        // Reset validation state
                        passwordInput.classList.remove('is-invalid-custom', 'is-valid-custom');
                        errorMsg.style.display = 'none';
                        errorMsg.textContent = '';
                        
                        // If empty, no validation needed (optional field)
                        if (!value) {
                            return true;
                        }
                        
                        // Check minimum length
                        if (value.length < 6) {
                            if (showErrors) {
                                passwordInput.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Mật khẩu phải có ít nhất 6 ký tự';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Valid
                        if (showErrors && value) {
                            passwordInput.classList.add('is-valid-custom');
                        }
                        return true;
                    }
                    
                    function validateBalance(showErrors) {
                        var balanceDisplay = document.getElementById('balanceDisplay');
                        var errorMsg = document.getElementById('balanceErrorMsg');
                        
                        if (!balanceDisplay || !errorMsg || balanceDisplay.readOnly) return true;
                        
                        var value = balanceDisplay.value.trim();
                        
                        // Reset validation state
                        balanceDisplay.classList.remove('is-invalid-custom', 'is-valid-custom');
                        errorMsg.style.display = 'none';
                        errorMsg.textContent = '';
                        
                        // If empty, no validation needed
                        if (!value || value === '0') {
                            return true;
                        }
                        
                        // Parse number (remove commas)
                        var cleaned = value.replace(/[^\d]/g, '');
                        var numValue = parseFloat(cleaned);
                        
                        // Check if valid number
                        if (isNaN(numValue)) {
                            if (showErrors) {
                                balanceDisplay.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Số dư phải là một số hợp lệ';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Check if negative
                        if (numValue < 0) {
                            if (showErrors) {
                                balanceDisplay.classList.add('is-invalid-custom');
                                errorMsg.textContent = 'Số dư không được nhỏ hơn 0';
                                errorMsg.style.display = 'block';
                            }
                            return false;
                        }
                        
                        // Valid
                        if (showErrors && value) {
                            balanceDisplay.classList.add('is-valid-custom');
                        }
                        return true;
                    }
                    
                    // Add event listeners for real-time validation (only on blur, not while typing)
                    var fullNameInput = document.getElementById('fullName');
                    if (fullNameInput) {
                        fullNameInput.addEventListener('blur', function() {
                            validateFullName(true);
                        });
                        fullNameInput.addEventListener('input', function() {
                            // Clear error when user starts typing
                            if (this.classList.contains('is-invalid-custom')) {
                                this.classList.remove('is-invalid-custom');
                                var errorMsg = document.getElementById('fullNameErrorMsg');
                                if (errorMsg) {
                                    errorMsg.style.display = 'none';
                                }
                            }
                        });
                    }
                    
                    var phoneInput = document.getElementById('phoneNumber');
                    if (phoneInput) {
                        phoneInput.addEventListener('blur', function() {
                            validatePhoneNumber(true);
                        });
                        phoneInput.addEventListener('input', function() {
                            // Clear error when user starts typing
                            if (this.classList.contains('is-invalid-custom')) {
                                this.classList.remove('is-invalid-custom');
                                var errorMsg = document.getElementById('phoneNumberErrorMsg');
                                if (errorMsg) {
                                    errorMsg.style.display = 'none';
                                }
                            }
                        });
                    }
                    
                    var newPasswordInput = document.getElementById('newPassword');
                    if (newPasswordInput) {
                        newPasswordInput.addEventListener('blur', function() {
                            validateNewPassword(true);
                            // Also validate confirm password if it has value
                            if (document.getElementById('confirmPassword').value) {
                                validatePasswordMatch(true);
                            }
                        });
                        newPasswordInput.addEventListener('input', function() {
                            // Clear error when user starts typing
                            if (this.classList.contains('is-invalid-custom')) {
                                this.classList.remove('is-invalid-custom');
                                var errorMsg = document.getElementById('newPasswordErrorMsg');
                                if (errorMsg) {
                                    errorMsg.style.display = 'none';
                                }
                            }
                        });
                    }
                    
                    var confirmPasswordInput = document.getElementById('confirmPassword');
                    if (confirmPasswordInput) {
                        confirmPasswordInput.addEventListener('blur', function() {
                            validatePasswordMatch(true);
                        });
                        confirmPasswordInput.addEventListener('input', function() {
                            // Clear error when user starts typing
                            if (this.classList.contains('is-invalid-custom') || passwordMatchError) {
                                this.classList.remove('is-invalid-custom');
                                if (passwordMatchError) {
                                    passwordMatchError.style.display = 'none';
                                }
                                var errorMsg = document.getElementById('confirmPasswordErrorMsg');
                                if (errorMsg) {
                                    errorMsg.style.display = 'none';
                                }
                            }
                        });
                    }
                    
                    var balanceDisplay = document.getElementById('balanceDisplay');
                    if (balanceDisplay && !balanceDisplay.readOnly) {
                        balanceDisplay.addEventListener('blur', function() {
                            validateBalance(true);
                        });
                        balanceDisplay.addEventListener('input', function() {
                            // Clear error when user starts typing
                            if (this.classList.contains('is-invalid-custom')) {
                                this.classList.remove('is-invalid-custom');
                                var errorMsg = document.getElementById('balanceErrorMsg');
                                if (errorMsg) {
                                    errorMsg.style.display = 'none';
                                }
                            }
                        });
                    }
                    
                    form.addEventListener('submit', function (event) {
                        formValidated = true;
                        
                        var isValid = true;
                        
                        // Validate all fields
                        if (!validateFullName(true)) isValid = false;
                        if (!validatePhoneNumber(true)) isValid = false;
                        if (!validateNewPassword(true)) isValid = false;
                        if (!validatePasswordMatch(true)) isValid = false;
                        if (!validateBalance(true)) isValid = false;
                        
                        if (!isValid) {
                            event.preventDefault();
                            event.stopPropagation();
                            form.classList.add('was-validated');
                            return false;
                        }
                        
                        if (form.checkValidity() === false) {
                            event.preventDefault();
                            event.stopPropagation();
                        }
                        form.classList.add('was-validated');
                    }, false);
                }, false);
            })();
            
            // Balance formatting
            (function() {
                var balanceDisplay = document.getElementById('balanceDisplay');
                var balanceInput = document.getElementById('balance');
                
                if (balanceDisplay && balanceInput) {
                    // Format number with commas
                    function formatNumber(num) {
                        if (!num || num === '0') return '0';
                        // Remove all non-digit characters
                        var cleaned = num.toString().replace(/[^\d]/g, '');
                        if (cleaned === '' || cleaned === '0') return '0';
                        // Add commas
                        return cleaned.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    }
                    
                    // Parse formatted number to actual number
                    function parseNumber(formatted) {
                        if (!formatted) return '0';
                        var cleaned = formatted.toString().replace(/[^\d]/g, '');
                        return cleaned === '' ? '0' : cleaned;
                    }
                    
                    // Only add event listeners if field is not readonly
                    if (!balanceDisplay.readOnly) {
                        // Update hidden input when display input changes
                        balanceDisplay.addEventListener('input', function() {
                            var cleaned = parseNumber(this.value);
                            balanceInput.value = cleaned;
                            // Format the display
                            this.value = formatNumber(cleaned);
                        });
                        
                        // Format on blur
                        balanceDisplay.addEventListener('blur', function() {
                            var cleaned = parseNumber(this.value);
                            balanceInput.value = cleaned;
                            this.value = formatNumber(cleaned);
                        });
                    }
                    
                    // Ensure hidden input has correct value on page load
                    if (balanceInput.value) {
                        var currentValue = parseNumber(balanceDisplay.value);
                        balanceInput.value = currentValue;
                    }
                }
            })();
        </script>
    </body>
</html>

