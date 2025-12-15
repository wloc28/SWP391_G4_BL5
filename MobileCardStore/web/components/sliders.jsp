<%-- 
    Document   : Sliders
    Created on : Jan 17, 2024, 10:26:10 AM
    Author     : songk
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>

<c:if test="${not empty sliders and sliders.size() > 0}">
    <div id="carousel" class="carousel carousel-dark slide m-5">
        <div class="carousel-indicators">
            <c:forEach var="i" begin="0" end="${sliders.size()-1}">
                <button type="button" data-bs-target="#carousel" data-bs-slide-to="${i}" class="${i==0?"active":""}" aria-label="Slide ${i+1}"></button>
            </c:forEach>
        </div>
        
        <div class="carousel-inner">
            <c:forEach var="item" items="${sliders}" varStatus="status">
                <div class="carousel-item ${status.first ? 'active' : ''}" data-bs-interval="1000">
                    <a href="sliderdetails?id=${item.id}">
                        <img class="bd-placeholder-img bd-placeholder-img-lg d-block w-100" 
                         width="800" height="400"  role="img" aria-label="Placeholder: First slide" 
                         preserveAspectRatio="xMidYMid slice" focusable="false" 
                         src="images/Sliders/${item.id}/Thumbnail/${item.image}"/>
                    </a>
                    <div class="carousel-caption d-none d-md-block">
                        <h5>${item.title}</h5>
                        <!--<p>Some representative placeholder content for the first slide.</p>-->
                    </div>
                </div>
            </c:forEach>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#carousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#carousel" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Next</span>
        </button>
    </div>
</c:if>
