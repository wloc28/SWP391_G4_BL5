
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>User detail</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

        <link href="https://fonts.googleapis.com/css?family=Poppins:300,400,500,600,700,800,900" rel="stylesheet">


        <link rel="stylesheet" href="css/styles.css">
        <%@include file="../components/libs.jsp" %>
    </head>
    <body>
        <%@include file="../components/header.jsp" %>
        <a href="ulist" class="btn btn-outline-danger" >Back to list</a>
        <c:set value="${requestScope.acc}" var="in"/>
        <c:if test="${in != null}">
            <div class="container-lg">
                <div>
                    <h3 class="text-bg-light text-body-emphasis font-monospace card my-4 align-baseline px-lg-5 fw-bold" style="text-align: center">Account detail</h3>
                </div>
                <div class="container-fluid form-group form-control-sm p-4" style="background: snow;border: 1px solid black;">                  


                    <table class="table">
                        <tr>
                            <td><img class="icon" id="image" style="border: 1px solid black;border-radius: 100%;width: 50px;height: 50px;" src="${in.avatar}" alt=""></td>
                            <td class="fw-bold fs-5">${in.username}</td>
                        </tr>
                        <tr>
                            <td>Email:</td>
                            <td>${in.email}</td>
                        </tr>
                        <tr>
                            <td>Age</td>
                            <td>${in.age}</td>
                        </tr>
                        <tr>
                            <td>Gender</td>
                            <td>${in.gender? 'Male' : 'Female' }</td>
                        </tr>
                        <tr>
                            <td>Address</td>
                            <td>${in.address}</td>
                        </tr>
                        <tr>
                            <td>Mobile</td>
                            <td>${in.mobile}</td>
                        </tr>
                        <c:if test="${param.act eq 'view'}">
                            <tr>
                                <td>Role</td>
                                <td>
                                    ${(in.role == 1) ? "Customer" : ""}
                                    ${(in.role == 2) ? "Admin" : "" }
                                  
                                </td>
                            </tr>
                            <tr>
                                <td>Status</td>
                                <td>${in.status ? 'Enable':'Disable'}</td>
                            </tr>
                        </c:if>
                    </table>

                    <c:if test="${param.act eq 'edit'}">
                        <div class="form-group" style="text-align: left;color: black">
                            Status<br>
                            <select class="btn custom-select mr-sm-2" style="background:${!in.status ? "#FF3333" : "#33CC66" };color: white;border: black 1px solid;font-weight: bold;" id="${in.email}" onchange="changeStatus(this.value, this.id)">
                                <option value="1"  ${in.status ? "selected" : "" }>
                                    Enable

                                </option>
                                <option value="0"  ${!in.status ? "selected" : "" }>
                                    Disable
                                </option>
                            </select>
                        </div>
                        <div class="form-group" style="text-align: left;color: black">
                            Role
                            <select class="input-group form-control mb-4 custom-select" style="width: 200px;" id="${in.email}" onchange="changeRole(this.value, this.id)" >
                                <option value="1" ${(in.role == 1) ? "selected" : "" } >Customer</option>
                                <option value="2" ${(in.role == 2) ? "selected" : "" } >Admin</option>
                               
                            </select>
                        </div>
                    </c:if>
                    <br>

                    <div class="form-group">
                        <c:if test="${param.act eq 'edit'}">
                            <a class="btn btn-outline-dark" onclick="confirmSave()"/>Confirm</a>
                        </c:if>
                        <c:if test="${param.act eq 'view'}">
                            <a class="btn btn-outline-dark" href="udetail?email=${param.email}&act=edit"/>Edit</a>
                        </c:if>
                        <a class="btn btn-outline-dark" href="ulist"/>Cancel</a>

                    </div>
                    <div class="form-group d-md-flex">

                    </div>


                </div>
            </div>
        </c:if>

        <!-- Add account -->
        <c:if test="${in == null}">
            <div class="container-lg">
                <div>
                    <h3 class="text-bg-light text-body-emphasis font-monospace card my-4 align-baseline px-lg-5 fw-bold" style="text-align: center">New Account</h3>
                </div>
                <div class="container-fluid form-group form-control-sm p-4" style="background: snow;border: 1px solid black;">
                    <form action="udetail" class="login-form fs-5" method="post">
                        <div class="row">
                            <div>
                                <h5 class="text-bg-light text-body-emphasis font-monospace card my-4 align-baseline px-lg-5 ">${sessionScope.accAddMess}</h5>
                            </div>    

                            <div class="form-group col-3 font-monospace fw-bold" style="color: black;">
                                Email
                            </div>
                            <div class="col-7 mb-4">
                                <input type="text"class="form-control rounded-left"  name="email" />
                            </div>

                            <div class="form-group col-3 font-monospace fw-bold" style="text-align: left;color: black">
                                Status</div>
                            <div class="col-7 mb-4">
                                <select name="status" class="btn custom-select mr-sm-2" style="color: black;border: black 1px solid;font-weight: bold;">

                                    <option value="1">
                                        Enable

                                    </option>
                                    <option value="0"  >
                                        Disable
                                    </option>
                                </select>
                            </div>
                            <div class="form-group col-3 font-monospace fw-bold" style="text-align: left;color: black">
                                Role</div>
                            <div class="col-7 mb-4">
                                <select name="role" class="input-group form-control mb-4 custom-select mr-sm-2" style="width: 200px;" >
                                    <option value="1"  >Customer</option>
                                    <option value="2"  >Admin</option>
                                 
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <button type="submit" class="btn btn-outline-dark btn-primary fw-bold" style="color: snow;" onclick="add()">Create account</button>
                            <a class="btn btn-outline-dark" href="ulist"/>Cancel</a>
                            <span aria-hidden="true" class="ion-ios-close"></span>
                        </div>
                        <div class="form-group d-md-flex">

                        </div>

                    </form>
                </div>
            </div>
        </c:if>

        <%@include file="../components/footer.jsp" %>
        <script>

            function confirmSave() {


                let a = confirm("Save success!");
            }
        </script>
        <script>
            function changeStatus(e, f) {
                var url = document.baseURI;
                var st;
                if (e == 0) {
                    st = "Disable";
                } else
                    st = "Enable";
                let a = confirm("Edit account " + f + " status " + st);
                if (a) {
                    window.location = "editu?email=" + f + "&status=" + e + "&url=" + url;
                }

            }
            function changeRole(e, f) {
                var url = document.baseURI;
                var st;
                if (e == 1) {
                    st = "Customer";
                } else {
                    if (e == 2) {
                        st = "Admin";
                   
                }




                let a = confirm("Edit account " + f + " role " + st);
                if (a) {
                    window.location = "editu?email=" + f + "&role=" + e + "&url=" + url;
                }

            }

        </script>
    </body>
</html>
