
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>



<c:if test="${sessionScope.info.role == 1 or sessionScope.info == null}">
<header class="p-3 bg-dark text-white">
    <div class="container">
        <div class="d-flex flex-wrap justify-content-between ">


            <ul class="nav  mb-2 justify-content-center mb-md-0">
                <li><a href="/OnlineLearning/home" class="d-flex align-items-center mb-2  text-white text-decoration-none">
                        <svg class="bi me-2" width="40" height="32" role="img" aria-label="Bootstrap"><use xlink:href="#bootstrap"></use></svg>
                    </a></li>
                <li><a href="home" class="nav-link px-2 text-secondary">Mobile Card Store</a></li>
               
            </ul>

          
            <c:if test="${sessionScope.info==null}">
                <div class="text-black">

                    <!-- comment -->
                    <button type="button" class="btn btn-outline-light me-2" data-bs-toggle="modal" data-bs-target="#popupLogin">
                        Login
                    </button>
                    <c:if test="${requestScope.page!=1}">
                        <div class="modal fade" id="popupLogin" tabindex="-1" aria-labelledby="popupLoginLabel" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content" style="background-color: #e9ecef">
                                    <div class="modal-header">
                                        <h2>Login</h2>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <c:if test="${requestScope.page!=1}">
                                        <div class="modal-body">
                                            <%@include file="loginForm.jsp" %>
                                        </div>
                                        <div class="modal-footer">

                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </div>
                    </c:if>
                    <!-- comment -->
                    <!-- comment -->
                    <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#popupRegister">
                        Sign-up
                    </button>
                    <c:if test="${requestScope.page!=1}">
                        <div class="modal fade" id="popupRegister" tabindex="-1" aria-labelledby="popupRegisterLabel" aria-hidden="true">
                            <div class="modal-dialog" >
                                <div class="modal-content " style="background-color: #e9ecef">
                                    <div class="modal-header">
                                        <h2>Register</h2>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>

                                    <div class="modal-body">
                                        <%@include file="registerForm.jsp" %>
                                    </div>
                                    <div class="modal-footer">

                                    </div>

                                </div>
                            </div>
                        </div>
                    </c:if>
                    <!-- comment -->
                </div>
            </c:if>
            <c:if test="${sessionScope.info!=null}">
                <div class="text-end">

                    <%@include file="../view/ChangePassword.jsp" %>
                    <a href="logout" type="button" class="btn btn-warning">Logout</a>
                </div>
            </c:if>

        </div>
    </div>
</header>
</c:if>
<c:if test="${sessionScope.info.role >= 2}">
    <header class="p-3 text-white" style="background-color: #51585e">
        <div class="container">
            <div class="d-flex flex-wrap justify-content-between ">


                <ul class="nav  mb-2 justify-content-center mb-md-0">
                    <li><a href="/OnlineLearning/home" class="d-flex align-items-center mb-2  text-white text-decoration-none">
                            <svg class="bi me-2" width="40" height="32" role="img" aria-label="Bootstrap"><use xlink:href="#bootstrap"></use></svg>
                        </a></li>
                    <li><a href="home" class="nav-link px-2 text-primary fw-bold">Home</a></li>
                    <c:if test="${sessionScope.info.role == 2}">
                    <li><a href="ulist" class="nav-link px-2 text-white fw-bold">Account</a></li>
                    </c:if>
                    <li><a href="pklist" class="nav-link px-2 text-white fw-bold">Price package</a></li>
                    <li><a href="plist" class="nav-link px-2 text-white fw-bold">Post</a></li>
                    <li><a href="sliderslist" class="nav-link px-2 text-white fw-bold">Sliders</a></li>
                    <li><a href="registrationslist" class="nav-link px-2 text-white fw-bold">Registrations</a></li>
                </ul>

                
                <c:if test="${sessionScope.info==null}">
                    <div class="text-black">

                        <!-- comment -->
                        <button type="button" class="btn btn-outline-light me-2" data-bs-toggle="modal" data-bs-target="#popupLogin">
                            Login
                        </button>
                        <c:if test="${requestScope.page!=1}">
                            <div class="modal fade" id="popupLogin" tabindex="-1" aria-labelledby="popupLoginLabel" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content" style="background-color: #e9ecef">
                                        <div class="modal-header">
                                            <h2>Login</h2>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <c:if test="${requestScope.page!=1}">
                                            <div class="modal-body">
                                                <%@include file="loginForm.jsp" %>
                                            </div>
                                            <div class="modal-footer">

                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                        <!-- comment -->
                        <!-- comment -->
                        <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#popupRegister">
                            Sign-up
                        </button>
                        <c:if test="${requestScope.page!=1}">
                            <div class="modal fade" id="popupRegister" tabindex="-1" aria-labelledby="popupRegisterLabel" aria-hidden="true">
                                <div class="modal-dialog" >
                                    <div class="modal-content " style="background-color: #e9ecef">
                                        <div class="modal-header">
                                            <h2>Register</h2>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>

                                        <div class="modal-body">
                                            <%@include file="registerForm.jsp" %>
                                        </div>
                                        <div class="modal-footer">

                                        </div>

                                    </div>
                                </div>
                            </div>
                        </c:if>
                        <!-- comment -->
                    </div>
                </c:if>
                <c:if test="${sessionScope.info!=null}">
                    <div class="text-end">

                        <%@include file="../view/ChangePassword.jsp" %>
                        <a href="logout" type="button" class="btn btn-warning">Logout</a>
                    </div>
                </c:if>

            </div>
        </div>
    </header>
    
</c:if>


<script>
    document.addEventListener('click', function (event) {
        var myDiv = document.getElementById('searchform');

        // Ki?m tra n?u s? ki?n click không n?m trong th? div
        if (!myDiv.contains(event.target)) {
            hideResult1();
        }
    });
    function updateSearch1() {
        var inputValue = document.getElementById("inputSearch").value;
        $.ajax({
            type: "POST",
            url: "searchpopup",
            data: {inputValue: inputValue},
            success: function (response) {
                document.getElementById("searchResult").innerHTML = response;
            }
        });
    }
    function showResult1() {
        var result = document.getElementById("searchResult");
        result.style.display = 'block';
    }
    function hideResult1() {
        var result = document.getElementById("searchResult");
        result.style.display = 'none';
    }

</script>
