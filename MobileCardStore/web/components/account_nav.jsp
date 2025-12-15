
<h2>Account </h2>
<nav>
    <ul class="nav-li" >
        <li class="${requestScope.url.endsWith("profile")?"selected":""}"  ><a  href="profile">Profile</a></li>
        <li class="${requestScope.url.endsWith("mycourse")?"selected":""}" ><a href="mycourse">My Courses</a></li>
        <li class="${requestScope.url.endsWith("registrations")?"selected":""}"><a href="myregistrations">My Registrations</a></li>
    </ul>
</nav>