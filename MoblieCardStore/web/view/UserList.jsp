<%-- 
    Document   : UserList
    Created on : Jan 28, 2024, 12:52:25 PM
    Author     : ACER
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>User List</title>
        <!-- Favicon-->
        <link rel="icon" type="image/x-icon" href="assets/favicon.ico" />
        <!-- Core theme CSS (includes Bootstrap)-->
        <link href="css/styles.css" rel="stylesheet" />
        <%@include file="../components/libs.jsp" %>
        <style class="ul">
            a{
                text-decoration: none;
                color: black;
            }
        </style>
    </head>
    <body style="ul">
        <%@include file="../components/header.jsp" %>
        <c:set var="u" value="${requestScope.data}"/>
        <div class="container">
            <div class="card mt-4 mb-4">
                <div class="card-header col-12">
                    <h3>  User manage</h3>
                </div>
                <div class="row">
                    <div class="col-9">
                        <form action="ulist" method="get" class="sform">
                            <div class="row">

                                <div class="card col-5 m-3">
                                    <h6 class="card-header">Search by</h6>
                                    <input style="width: 350px;" class="form-control" type="text" name="name" placeholder="Search name" value="${param.name}"/>
                                    <input style="width: 350px;" class="form-control" type="text" name="email" placeholder="Search email" value="${param.email}"/>
                                    <input style="width: 350px;" class="form-control" type="text" name="mobile" placeholder="Search mobile" value="${param.mobile}"/>
                                </div>
                                <div class="card col-6 m-3">
                                    <h6 class="card-header">Filter by</h6>
                                    <p class="card-header w-25 fw-bold">Status</p>
                                    <div class="form-check">
                                        <input  name="stat" type="radio"  value="-1" ${param.stat == -1? "checked" : ""} />
                                        <label>All</label>
                                        <input  name="stat"  type="radio"  value="0" ${param.stat eq "0"? "checked" : "" }/>Disable
                                        <input  name="stat" type="radio"  value="1" ${param.stat eq "0" or param.stat eq "-1"? "" : "checked" }/>Enable
                                        

                                    </div>
                                    <p class="card-header w-25 fw-bold">Gender</p>
                                    <div class="form-check">
                                        <input name="gen" type="radio" value="-1" checked=""} />All
                                        <input name="gen"  type="radio" value="0" ${param.gen == "0"? "checked" : "" } />Female
                                        <input onclick="ulist" name="gen"  type="radio"  value="1" ${param.gen == "1"? "checked" : "" } />Male


                                    </div>
                                    <p class="card-header w-25 fw-bold">Role</p>
                                    <select class="form-control w-75" name="role">
                                        <option value="-1"  >All</option>
                                        <option value="1" ${(param.role eq "1") ? "selected" : "" } >Customer</option>
                                        <option value="2" ${(param.role eq "2") ? "selected" : "" } >Admin</option>
                                        
                                    </select>
                                </div>

                                <div>
                                    <button type="submit" class="btn btn-warning btn-outline-dark">Search</button>
                                    <a class="btn btn-outline-primary" href="ulist">Reset</a>

                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="col-2 card m-3">
                        <h6 class="card-header">Sort by</h6>

                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=AID&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">ID <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=username&page${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">User Name <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=gender&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">Gender <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=email&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">Email <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=mobile&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">Mobile <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=role&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">Role <img src="img/sort.png" alt="alt"/></a>
                        <a class="btn btn-outline-dark fw-bold w-75" href="ulist?filter=status&page=${param.page}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">Status <img src="img/sort.png" alt="alt"/></a>
                        <h6 class="card-header">Order by</h6>   
                        <div class="col-md-9">
                            <form action="ulist" method="post">

                                <button type="submit" class="btn-outline-dark btn" name="sort" value="desc"><img src="img/DESC.png" alt="alt"/></button>
                                <button type="submit" class="btn-outline-dark btn" name="sort" value="asc"><img src="img/ASC.png" alt="alt"/></button>
                            </form>
                        </div>
                    </div>


                </div>
                <div class="card-header">
                    <h6>Total of record: ${requestScope.record}</h6>
                </div>

                <div class="container m-4" style="display: flex;">



                    <div class="col-md-3">
                        <a href="udetail" class="btn btn-outline-danger" >Add new account</a>
                    </div>
                    <button class="btn btn-outline-dark" data-toggle="modal" data-target="#uhistory" type="button">History</button>
            

                </div>
                <div class="container">
                    <div class="table-responsive-sm">
                        <table class="table">
                            <thead class="thead-dark" style="background: lightgrey;height: 40px;color: ">


                                <tr class="card-header table-bordered table-active" style="height: 45px;" >

                                    <th scope="col">ID</th>
                                    <th scope="col">User Name</th>
                                    <th scope="col">Gender</th>
                                    <th scope="col">Email</th>
                                    <th scope="col">Mobile</th>
                                    <th scope="col">Role</th>
                                    <th scope="col">Status</th>
                                    <th scope="col">Action 
                                    </th>

                                </tr>
                            </thead>
                            <c:if test="${!u.isEmpty()}" >  
                                <c:forEach begin="0" end="${u.size() - 1}" var="i">

                                    <tr  style="${(i % 2 == 1)?"background-color: lightcyan;":""}">

                                        <td style="width: 90px;">
                                            ${u.get(i).getAid()}
                                        </td>
                                        <td style="width: 200px;">
                                            ${u.get(i).getUsername()}
                                        </td>
                                        <td style="width: 160px;">
                                            ${u.get(i).isGender()? "Male" : "FeMale" }<br>

                                        </td>
                                        <td style="width: 170px;">
                                            ${u.get(i).getEmail()}
                                        </td>
                                        <td style="width: 120px;">
                                            ${u.get(i).getMobile()}
                                        </td>

                                        <td style="width: 200px;">
                                            <select class="input-group form-control rounded-left" id="${u.get(i).getEmail()}" onchange="changeRole(this.value, this.id)" >
                                                <option value="1" ${(u.get(i).getRole() == 1) ? "selected" : "" } >Customer</option>
                                                <option value="2" ${(u.get(i).getRole() == 2) ? "selected" : "" } >Admin</option>
                                                <option value="3" ${(u.get(i).getRole() == 3) ? "selected" : "" } >Marketing Manager</option>
                                                <option value="4" ${(u.get(i).getRole() == 4) ? "selected" : "" } >Manager</option>
                                            </select>
                                        </td>
                                        <td style="width: 150px;">
                                            <select class="input-group form-control rounded-left" style="background: ${(!   u.get(i).isStatus()) ? "#FF3333" : "#33CC66" };color: white;border: black 1px solid;font-weight: bold;" id="${u.get(i).getEmail()}" onchange="changeStatus(this.value, this.id)">
                                                <option value="1"  ${(u.get(i).isStatus()) ? "selected" : "" }>
                                                    Enable

                                                </option>
                                                <option value="0"  ${!(u.get(i).isStatus()) ? "selected" : "" }>
                                                    Disable
                                                </option>
                                            </select>


                                        </td>
                                        <td>
                                            <a class="btn btn-secondary" href="udetail?email=${u.get(i).getEmail()}&act=view"><img src="img/eye.png" alt="alt"/></a>
                                            <a class="btn btn-outline-dark" href="udetail?email=${u.get(i).getEmail()}&act=edit"><img src="img/edit.png" alt="alt"/></a>
                                            
                                            <button class="btn btn-warning btn-outline-dark" type="button" value="${u.get(i).getEmail()}" onclick="dodelete(this)"><img src="img/delete.png" alt="alt"/></button>
                                            
                                        </td>
                                    </tr>

                                </c:forEach></c:if>    
                            </table>
                        </div>
                    </div>
                    <nav aria-label="Pagination">
                        <hr class="my-0" />
                        <ul class="pagination justify-content-center my-4">
                        <c:forEach begin="1" end="${requestScope.num}" var="page">

                            <li class="page-item"><a class="page-link" href="ulist?page=${page}&filter=${param.filter}&name=${param.name}&email=${param.email}&mobile=${param.mobile}&stat=${param.stat}&gen=${param.gen}&role=${param.role}">${page}</a></li>
                            </c:forEach>
                    </ul>
                </nav>

            </div>
        </div>

    
    <div class="modal fade" id="uhistory" tabindex="-1" role="dialog"  aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered" style="max-width: 50%;" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 style="color: black">History</h4>
                        <button type="button" class="close d-flex align-items-center justify-content-center" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true" class="ion-ios-close">X</span>
                        </button>

                    </div>
                    <div class="modal-body p-5 p-md-5">
                        <div class="icon d-flex align-items-center justify-content-center">
                            <span class="ion-ios-person"></span>
                        </div>
                        <table class="table">
                            <tr class="table-primary">
                                <th>Action</th>
                                <th>Time</th>
                                <th>Item</th>
                                <th>Status</th>
                                <th>Note</th>
                            </tr>
                            ${cookie.uhistory.value}
                        </table>


                    </div>

                </div>
            </div>
        </div>
                        <%@include file="../components/footer.jsp" %>
    <script>
        function changeStatus(e, f) {
            var st;
            if (e == 0) {
                st = "Disable";
            } else
                st = "Enable";
            let a = confirm("Edit account " + f + " status " + st);
            if (a) {
                window.location = "editu?email=" + f + "&status=" + e;
            } else {
                var url = document.URL;
                
            }


        }
        function changeRole(e, f) {
            var st;
            if (e == 1) {
                st = "Customer";
            } else {
                if (e == 2) {
                    st = "Admin";
                } else {
                    if (e == 3) {
                        st = "Marketing Manager";
                    } else {
                        st = "Manager";
                    }
                }
            }




            let a = confirm("Edit account " + f + " role " + st);
            if (a) {
                window.location = "editu?email=" + f + "&role=" + e;
            } else {
                var url = document.URL;
                window.location = "url";
            }

        }
        function  dodelete(e) {
            let a = confirm("Delete account " + e.value);
            if (a) {
                window.location = "delacc?email=" + e.value;
            } else {
                window.location = "ulist";
            }
            let b = confirm("Success");
        }
    </script>
</body>
</html>
