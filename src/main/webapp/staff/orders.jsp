<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<jsp:include page="common/staff-header.jsp" />

<div class="row mb-4">
    <div class="col-12">
        <h2 class="fw-bold text-dark"><i class="bi bi-card-list text-warning me-2"></i>Bảng Quản Lý Nhận Đơn Hàng</h2>
        <p class="text-muted">Xem, nhận đơn từ mã QR khách hàng gọi và cập nhật tiến trình chế biến của bếp.</p>
    </div>
</div>

<!-- Hiển thị thông báo kết quả hành động -->
<c:if test="${not empty sessionScope.orderSuccess}">
    <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px;">
        <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.orderSuccess}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>
<c:if test="${not empty sessionScope.orderError}">
    <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert" style="border-radius: 10px;">
        <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.orderError}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
</c:if>

<!-- Thanh bộ lọc trạng thái (Tabs) -->
<div class="card border-0 shadow-sm mb-4" style="border-radius: 12px; overflow: hidden;">
    <div class="card-body p-2 bg-white">
        <ul class="nav nav-pills nav-fill">
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'active' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders">
                    <i class="bi bi-lightning-charge me-1"></i> Cần Xử Lý
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'ChoThanhToan' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=ChoThanhToan">
                    <i class="bi bi-hourglass-split me-1"></i> Chờ Thanh Toán
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'DangCheBien' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=DangCheBien">
                    <i class="bi bi-fire me-1"></i> Đang Chế Biến
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'DaGiao' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=DaGiao">
                    <i class="bi bi-check2-square me-1"></i> Đã Giao Món
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'DaThanhToan' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=DaThanhToan">
                    <i class="bi bi-currency-dollar me-1"></i> Đã Thanh Toán
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'DaHuy' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=DaHuy">
                    <i class="bi bi-x-circle me-1"></i> Đã Hủy
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link py-2.5 ${currentTab == 'all' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}" 
                   href="${pageContext.request.contextPath}/staff/orders?status=All">
                    <i class="bi bi-list-nested me-1"></i> Tất Cả
                </a>
            </li>
        </ul>
    </div>
</div>

<!-- Khối danh sách đơn hàng -->
<div class="custom-card">
    <div class="table-responsive">
        <table class="table table-hover align-middle custom-table">
            <thead>
                <tr>
                    <th style="width: 80px;">Mã Đơn</th>
                    <th>Thời Gian Đặt</th>
                    <th>Hình Thức / Vị Trí</th>
                    <th>Khách Hàng</th>
                    <th class="text-end">Tổng Tiền</th>
                    <th>Phụ Trách</th>
                    <th class="text-center">Trạng Thái</th>
                    <th class="text-center" style="width: 280px;">Hành Động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="order" items="${orders}">
                    <tr>
                        <td>
                            <strong class="text-dark">#${order.maHoaDon}</strong>
                        </td>
                        <td>
                            <span class="text-muted" style="font-size: 0.9rem;">
                                <fmt:formatDate value="${order.ngayTao}" pattern="dd/MM/yyyy HH:mm:ss" />
                            </span>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${order.loaiHoaDon == 'TaiCho'}">
                                    <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill">
                                        <i class="bi bi-shop me-1"></i> ${not empty order.table ? order.table.tenBan : 'Tại quán'}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill">
                                        <i class="bi bi-bag-dash me-1"></i> Mang về
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td>
                            <div class="fw-semibold text-dark">${order.customer.hoTen}</div>
                            <small class="text-muted"><i class="bi bi-telephone me-1"></i>${order.customer.soDienThoai}</small>
                        </td>
                        <td class="text-end fw-bold text-dark">
                            <fmt:formatNumber value="${order.tongTien}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty order.user}">
                                    <span class="text-secondary" style="font-size: 0.95rem;">
                                        <i class="bi bi-person-badge me-1"></i>${order.user.hoTen}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="text-danger fw-semibold" style="font-size: 0.9rem;">
                                        <i class="bi bi-patch-question me-1"></i>Chưa nhận đơn
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <c:choose>
                                <c:when test="${order.trangThai == 'ChoThanhToan'}">
                                    <span class="badge-status status-chothanhtoan">Chờ thanh toán</span>
                                </c:when>
                                <c:when test="${order.trangThai == 'DangCheBien'}">
                                    <span class="badge-status status-dangchebien">Đang chế biến</span>
                                </c:when>
                                <c:when test="${order.trangThai == 'DaGiao'}">
                                    <span class="badge-status status-dagiao">Đã giao món</span>
                                </c:when>
                                <c:when test="${order.trangThai == 'DaThanhToan'}">
                                    <span class="badge-status status-dathanhtoan">Đã thanh toán</span>
                                </c:when>
                                <c:when test="${order.trangThai == 'DaHuy'}">
                                    <span class="badge-status status-dahuy">Đã hủy</span>
                                </c:when>
                            </c:choose>
                        </td>
                        <td class="text-center">
                            <div class="d-flex justify-content-center align-items-center gap-1">
                                <!-- Nút Xem chi tiết Popup Modal & Link toàn trang -->
                                <button type="button" class="btn btn-sm btn-outline-secondary px-3 py-1.5" style="border-radius: 8px;"
                                        onclick="showOrderDetailModal(${order.maHoaDon})">
                                    <i class="bi bi-eye-fill"></i> Chi Tiết
                                </button>

                                <!-- Template ẩn chứa dữ liệu chi tiết của đơn hàng -->
                                <div id="order-data-${order.maHoaDon}" class="d-none"
                                     data-id="${order.maHoaDon}"
                                     data-date="<fmt:formatDate value='${order.ngayTao}' pattern='dd/MM/yyyy HH:mm:ss' />"
                                     data-status="${order.trangThai}"
                                     data-type="${order.loaiHoaDon}"
                                     data-location="${order.loaiHoaDon == 'TaiCho' ? (not empty order.table ? order.table.tenBan : 'Tại quán') : 'Mang về'}"
                                     data-customer-name="${order.customer.hoTen}"
                                     data-customer-phone="${order.customer.soDienThoai}"
                                     data-customer-points="${order.customer.diemTichLuy}"
                                     data-staff-name="${not empty order.user ? order.user.hoTen : 'Chưa nhận'}"
                                     data-total="${order.tongTien}"
                                     data-formatted-total="<fmt:formatNumber value='${order.tongTien}' type='currency' currencySymbol='đ' maxFractionDigits='0' />"
                                     data-note="${order.ghiChu}">
                                    
                                    <div class="items-list">
                                        <c:forEach var="detail" items="${order.orderDetails}">
                                            <div class="d-flex align-items-center justify-content-between p-2 mb-2 bg-white rounded border">
                                                <div class="d-flex align-items-center gap-2">
                                                     <c:choose>
                                                         <c:when test="${not empty detail.drink.hinhAnh}">
                                                             <c:set var="detailImg" value="${detail.drink.hinhAnh}" />
                                                             <c:if test="${!detail.drink.hinhAnh.startsWith('http') && !detail.drink.hinhAnh.startsWith('data:') && !detail.drink.hinhAnh.startsWith('/')}">
                                                                 <c:set var="detailImg" value="${pageContext.request.contextPath}/admin/images/${detail.drink.hinhAnh}" />
                                                             </c:if>
                                                             <img src="${detailImg}" class="rounded border" style="width: 42px; height: 42px; object-fit: cover;" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${detail.drink.hinhAnh}';">
                                                         </c:when>
                                                        <c:otherwise>
                                                            <div class="rounded border bg-light text-muted d-flex align-items-center justify-content-center" style="width: 42px; height: 42px;">
                                                                <i class="bi bi-cup-hot fs-5"></i>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div>
                                                        <strong class="d-block text-dark" style="font-size: 0.95rem;">${detail.drink.tenSanPham}</strong>
                                                        <small class="text-muted"><fmt:formatNumber value="${detail.donGia}" type="currency" currencySymbol="đ" maxFractionDigits="0" /> x ${detail.soLuong}</small>
                                                        <c:if test="${not empty detail.ghiChu}">
                                                            <small class="text-danger d-block fst-italic">*Y/c: ${detail.ghiChu}</small>
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <span class="fw-bold text-success">
                                                    <fmt:formatNumber value="${detail.donGia * detail.soLuong}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                                </span>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>

                                <!-- Hành động nhanh theo trạng thái (Bắt buộc xem Chi Tiết trước khi Bắt đầu Làm Món) -->
                                <c:choose>
                                    <c:when test="${order.trangThai == 'DangCheBien'}">
                                        <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">
                                            <input type="hidden" name="action" value="update-status">
                                            <input type="hidden" name="id" value="${order.maHoaDon}">
                                            <input type="hidden" name="status" value="DaGiao">
                                            <button type="submit" class="btn btn-sm btn-primary px-3 py-1.5 fw-bold" style="border-radius: 8px;">
                                                <i class="bi bi-check2-circle me-1"></i> Giao món
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:when test="${order.trangThai == 'DaGiao'}">
                                        <c:set var="itemsStr" value="" />
                                        <c:forEach var="detail" items="${order.orderDetails}" varStatus="vs">
                                            <c:set var="itemsStr" value="${itemsStr}${detail.soLuong}x ${detail.drink.tenSanPham}${!vs.last ? ', ' : ''}" />
                                        </c:forEach>
                                        <button type="button" class="btn btn-sm btn-success px-3 py-1.5 fw-bold" style="border-radius: 8px;"
                                                data-bs-toggle="modal" 
                                                data-bs-target="#paymentConfirmModal"
                                                data-id="${order.maHoaDon}"
                                                data-customer-name="${order.customer.hoTen}"
                                                data-customer-phone="${order.customer.soDienThoai}"
                                                data-staff-name="${not empty order.user ? order.user.hoTen : 'Chưa nhận'}"
                                                data-total-amount="${order.tongTien}"
                                                data-items="${itemsStr}">
                                            <i class="bi bi-currency-dollar me-1"></i> Thanh toán
                                        </button>
                                    </c:when>
                                </c:choose>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty orders}">
                    <tr>
                        <td colspan="8" class="text-center py-5 text-muted">
                            <i class="bi bi-inbox fs-1 d-block mb-3 text-secondary"></i>
                            Không tìm thấy đơn hàng nào ở trạng thái này.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>

    <!-- Nút Xem Thêm Đơn Hàng (Staff Load More) -->
    <div id="loadMoreStaffOrderContainer" class="text-center p-3 border-top bg-light rounded-bottom" style="${hasMore ? '' : 'display: none;'}">
        <div class="mb-2 text-muted small">
            Đã hiển thị <strong id="displayedStaffCount">${displayedCount}</strong> / <strong id="totalStaffCount">${totalCount}</strong> đơn hàng
        </div>
        <button type="button" id="btnLoadMoreStaffOrders" class="btn btn-outline-warning text-dark fw-bold px-4 py-2 rounded-pill shadow-sm" onclick="loadMoreStaffOrders()">
            <i class="bi bi-arrow-down-circle me-1"></i> Xem Thêm Đơn Hàng
        </button>
    </div>
</div>

<%
    session.removeAttribute("orderSuccess");
    session.removeAttribute("orderError");
%>

<!-- Modal Popup Xem Chi Tiết Đơn Hàng -->
<div class="modal fade" id="orderDetailModal" tabindex="-1" aria-labelledby="orderDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 18px;">
            <div class="modal-header bg-dark text-white py-3" style="border-radius: 18px 18px 0 0;">
                <div class="d-flex align-items-center gap-2">
                    <h5 class="modal-title fw-bold" id="detailModalTitle">
                        <i class="bi bi-receipt me-2 text-warning"></i>Chi Tiết Đơn Hàng #0
                    </h5>
                    <span id="detailModalStatusBadge"></span>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <div class="modal-body p-4">
                <!-- Thông tin khách hàng & thời gian -->
                <div class="row g-3 mb-4 p-3 bg-light rounded-3 border">
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-clock me-1"></i>Thời gian:</span>
                        <strong class="text-dark small" id="detailModalDate">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-shop me-1"></i>Hình thức:</span>
                        <strong class="text-success small" id="detailModalLocation">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-person me-1"></i>Khách hàng:</span>
                        <strong class="text-dark small" id="detailModalCustomer">---</strong>
                    </div>
                    <div class="col-6 col-md-3">
                        <span class="text-muted small d-block"><i class="bi bi-telephone me-1"></i>Số điện thoại:</span>
                        <strong class="text-dark small" id="detailModalPhone">---</strong>
                    </div>
                </div>

                <!-- Danh sách món nước -->
                <h6 class="fw-bold mb-3 text-dark"><i class="bi bi-cup-straw text-warning me-2"></i>Danh Sách Món Đặt:</h6>
                <div id="detailModalItemsContainer" class="mb-4" style="max-height: 250px; overflow-y: auto;">
                    <!-- JS injects items here -->
                </div>

                <!-- Ghi chú đơn hàng -->
                <div class="mb-4 p-3 bg-light rounded border" id="detailModalNoteBox">
                    <span class="text-secondary small d-block mb-1"><i class="bi bi-pencil-square me-1"></i>Ghi chú / Thông tin giảm giá:</span>
                    <span class="text-dark fw-semibold" id="detailModalNote">---</span>
                </div>

                <!-- Tổng tiền -->
                <div class="d-flex justify-content-between align-items-center bg-success-subtle p-3 rounded-3 border border-success-subtle">
                    <span class="fs-6 text-success-emphasis fw-bold">TỔNG TIỀN CẦN THU:</span>
                    <span class="fs-3 fw-black text-success" id="detailModalTotal" style="font-weight: 800;">0 đ</span>
                </div>
            </div>

            <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2 justify-content-end">
                <div class="d-flex gap-2" id="detailModalActionContainer">
                    <!-- Dynamic action buttons -->
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal Xác Nhận Thanh Toán -->
<div class="modal fade" id="paymentConfirmModal" tabindex="-1" aria-labelledby="paymentConfirmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 16px;">
            <div class="modal-header bg-success text-white py-3" style="border-radius: 16px 16px 0 0;">
                <h5 class="modal-title fw-bold" id="paymentConfirmModalLabel">
                    <i class="bi bi-check2-circle me-2"></i>Xác Nhận Thanh Toán Đơn Hàng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">
                <input type="hidden" name="action" value="update-status">
                <input type="hidden" name="id" id="modalOrderId" value="">
                <input type="hidden" name="status" value="DaThanhToan">
                
                <div class="modal-body p-4">
                    <div class="text-center mb-4">
                        <span class="text-muted small uppercase tracking-wider d-block mb-1">MÃ HÓA ĐƠN</span>
                        <h3 class="fw-bold text-success mb-0 fs-2" id="displayOrderId">#00</h3>
                    </div>
                    
                    <div class="row g-3 mb-3">
                        <div class="col-6">
                            <span class="text-muted small d-block mb-1"><i class="bi bi-person me-1"></i>Khách Hàng</span>
                            <strong class="text-dark fs-6 d-block" id="displayCustomerName">Tên Khách</strong>
                        </div>
                        <div class="col-6">
                            <span class="text-muted small d-block mb-1"><i class="bi bi-telephone me-1"></i>Số Điện Thoại</span>
                            <strong class="text-dark fs-6 d-block" id="displayCustomerPhone">090****000</strong>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <span class="text-muted small d-block mb-1"><i class="bi bi-person-badge me-1"></i>Nhân Viên Phụ Trách</span>
                        <strong class="text-secondary d-block" id="displayStaffName">Tên Nhân Viên</strong>
                    </div>
                    
                    <div class="mb-4">
                        <span class="text-muted small d-block mb-2"><i class="bi bi-receipt me-1"></i>Danh Sách Món Đã Đặt</span>
                        <div class="bg-light p-3 rounded-3 border border-light" id="displayDrinkItems" style="max-height: 160px; overflow-y: auto;">
                            <!-- JS will inject list items here -->
                        </div>
                    </div>
                    
                    <div class="d-flex justify-content-between align-items-center bg-success-subtle p-3 rounded-3 border border-success-subtle">
                        <span class="fs-6 text-success-emphasis fw-bold">Tổng tiền cần thu:</span>
                        <span class="fs-3 fw-black text-success" id="displayTotalAmount" style="font-weight: 800;">0 đ</span>
                    </div>
                </div>
                
                <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                    <button type="button" class="btn btn-light border flex-grow-1 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">
                        Hủy
                    </button>
                    <button type="submit" class="btn btn-success flex-grow-1 py-2 fw-bold" style="border-radius: 10px;">
                        <i class="bi bi-credit-card-2-back me-1"></i> Xác Nhận Thanh Toán
                    </button>
                </div>
            </form>
        </div>
    </div>
<style>
    /* CSS giúp Popup Hủy Đơn Hàng hiển thị nổi bật đè lên trên Popup Chi Tiết */
    #orderDetailModal { z-index: 1055 !important; }
    #paymentConfirmModal { z-index: 1055 !important; }
    #cancelOrderModal { z-index: 1070 !important; }
    
    /* Xử lý z-index cho lớp mờ (Backdrop) khi có nhiều Popup xếp đè lên nhau */
    .modal-backdrop { z-index: 1050 !important; }
    .modal-backdrop + .modal-backdrop { z-index: 1065 !important; }
</style>

<!-- Modal Xác Nhận Hủy Đơn Hàng kèm lý do & chi tiết món (NẰM ĐÈ LÊN POPUP CHI TIẾT) -->
<div class="modal fade" id="cancelOrderModal" tabindex="-1" aria-labelledby="cancelOrderModalLabel" aria-hidden="true" style="z-index: 1070;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg" style="border-radius: 18px;">
            <div class="modal-header bg-danger text-white py-3" style="border-radius: 18px 18px 0 0;">
                <h5 class="modal-title fw-bold" id="cancelOrderModalLabel">
                    <i class="bi bi-x-circle-fill me-2"></i>Xác Nhận Hủy Đơn Hàng
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            
            <form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">
                <input type="hidden" name="action" value="update-status">
                <input type="hidden" name="id" id="cancelModalOrderId" value="">
                <input type="hidden" name="status" value="DaHuy">
                
                <div class="modal-body p-4">
                    <div class="text-center mb-3">
                        <span class="text-muted small uppercase tracking-wider d-block mb-1">MÃ HÓA ĐƠN XÁC NHẬN HỦY</span>
                        <h3 class="fw-bold text-danger mb-0 fs-2" id="cancelModalDisplayOrderId">#00</h3>
                    </div>
                    
                    <div class="row g-2 mb-3 bg-light p-2.5 rounded-3 border small">
                        <div class="col-6">
                            <span class="text-muted d-block"><i class="bi bi-person me-1"></i>Khách hàng:</span>
                            <strong class="text-dark d-block" id="cancelModalCustomerName">---</strong>
                        </div>
                        <div class="col-6">
                            <span class="text-muted d-block"><i class="bi bi-telephone me-1"></i>SĐT:</span>
                            <strong class="text-dark d-block" id="cancelModalCustomerPhone">---</strong>
                        </div>
                    </div>
                    
                    <!-- Danh sách món nước chi tiết -->
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold mb-1">
                            <i class="bi bi-receipt me-1"></i>Chi tiết các món nước đã đặt:
                        </label>
                        <div class="bg-light p-3 rounded-3 border" id="cancelModalItemsContainer" style="max-height: 160px; overflow-y: auto;">
                            <!-- JS injects drink items here -->
                        </div>
                    </div>
                    
                    <!-- Ô nhập lý do hủy đơn -->
                    <div class="mb-3">
                        <label for="cancelReasonInput" class="form-label text-danger small fw-bold mb-1">
                            <i class="bi bi-pencil-square me-1"></i>Lý do hủy đơn hàng <span class="text-danger">*</span>
                        </label>
                        <textarea class="form-control" id="cancelReasonInput" name="cancelReason" rows="3"
                                  placeholder="Nhập lý do hủy (Ví dụ: Khách đổi ý, Hết nguyên liệu pha chế, Khách vắng mặt...)" required></textarea>
                    </div>

                    <div class="d-flex justify-content-between align-items-center bg-danger bg-opacity-10 p-3 rounded-3 border border-danger border-opacity-25">
                        <span class="small text-danger fw-bold">Tổng tiền đơn hủy:</span>
                        <span class="fs-4 fw-bold text-danger" id="cancelModalTotal">0 đ</span>
                    </div>
                </div>
                
                <div class="modal-footer border-0 p-3 pt-0 d-flex gap-2">
                    <button type="button" class="btn btn-light border flex-grow-1 py-2 fw-semibold" data-bs-dismiss="modal" style="border-radius: 10px;">
                        Quay lại
                    </button>
                    <button type="submit" class="btn btn-danger flex-grow-1 py-2 fw-bold" style="border-radius: 10px;">
                        <i class="bi bi-x-circle me-1"></i> Xác Nhận Hủy Đơn
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    // Hàm mở Popup Modal Xác Nhận Hủy Đơn Hàng nằm ĐÈ LÊN Popup Chi Tiết (Không bị đen màn hình)
    function openCancelOrderModal(orderId) {
        const dataEl = document.getElementById("order-data-" + orderId);
        if (!dataEl) return;

        document.getElementById("cancelModalOrderId").value = orderId;
        document.getElementById("cancelModalDisplayOrderId").innerText = "#" + orderId;
        document.getElementById("cancelModalCustomerName").innerText = dataEl.getAttribute("data-customer-name") || "Khách vãng lai";
        document.getElementById("cancelModalCustomerPhone").innerText = dataEl.getAttribute("data-customer-phone") || "N/A";
        document.getElementById("cancelModalTotal").innerText = dataEl.getAttribute("data-formatted-total");
        
        // Reset lý do hủy
        const reasonInput = document.getElementById("cancelReasonInput");
        if (reasonInput) reasonInput.value = "";

        // Đổ danh sách món
        const itemsListEl = dataEl.querySelector(".items-list");
        document.getElementById("cancelModalItemsContainer").innerHTML = itemsListEl ? itemsListEl.innerHTML : '';

        const cancelModalEl = document.getElementById('cancelOrderModal');
        if (cancelModalEl && cancelModalEl.parentNode !== document.body) {
            document.body.appendChild(cancelModalEl);
        }

        const cancelModal = bootstrap.Modal.getOrCreateInstance(cancelModalEl);
        cancelModal.show();
    }

    // Hàm hiển thị Modal Xem Chi Tiết Đơn Hàng
    function showOrderDetailModal(orderId) {
        const dataEl = document.getElementById("order-data-" + orderId);
        if (!dataEl) return;

        document.getElementById("detailModalTitle").innerHTML = '<i class="bi bi-receipt me-2 text-warning"></i>Chi Tiết Đơn Hàng #' + orderId;
        document.getElementById("detailModalDate").innerText = dataEl.getAttribute("data-date");
        document.getElementById("detailModalLocation").innerText = dataEl.getAttribute("data-location");
        document.getElementById("detailModalCustomer").innerText = dataEl.getAttribute("data-customer-name");
        document.getElementById("detailModalPhone").innerText = dataEl.getAttribute("data-customer-phone");
        document.getElementById("detailModalTotal").innerText = dataEl.getAttribute("data-formatted-total");
        
        const note = dataEl.getAttribute("data-note");
        document.getElementById("detailModalNote").innerText = note ? note : 'Không có ghi chú nào.';

        // Hiển thị trạng thái
        const status = dataEl.getAttribute("data-status");
        const statusBadgeEl = document.getElementById("detailModalStatusBadge");
        if (statusBadgeEl) {
            let badgeHtml = '';
            if (status === 'ChoThanhToan') badgeHtml = '<span class="badge-status status-chothanhtoan">Chờ thanh toán</span>';
            else if (status === 'DangCheBien') badgeHtml = '<span class="badge-status status-dangchebien">Đang chế biến</span>';
            else if (status === 'DaGiao') badgeHtml = '<span class="badge-status status-dagiao">Đã giao món</span>';
            else if (status === 'DaThanhToan') badgeHtml = '<span class="badge-status status-dathanhtoan">Đã thanh toán</span>';
            else if (status === 'DaHuy') badgeHtml = '<span class="badge-status status-dahuy">Đã hủy</span>';
            statusBadgeEl.innerHTML = badgeHtml;
        }

        // Đổ danh sách đồ uống
        const itemsListEl = dataEl.querySelector(".items-list");
        document.getElementById("detailModalItemsContainer").innerHTML = itemsListEl ? itemsListEl.innerHTML : '';

        // Đường dẫn đến trang chi tiết đầy đủ (nếu có)
        const fullPageBtn = document.getElementById("detailModalFullPageBtn");
        if (fullPageBtn) {
            fullPageBtn.href = "${pageContext.request.contextPath}/staff/orders/detail?id=" + orderId;
        }

        // Các nút thao tác nhanh
        const actionContainer = document.getElementById("detailModalActionContainer");
        let actionsHtml = '';

        // Nút Hủy Đơn Hàng (Chỉ hiển thị khi đơn chưa hoàn thành hoặc chưa bị hủy)
        if (status !== 'DaThanhToan' && status !== 'DaHuy') {
            actionsHtml += '<button type="button" class="btn btn-outline-danger fw-bold py-2 px-3" style="border-radius: 10px;" onclick="openCancelOrderModal(' + orderId + ')">' +
                           '  <i class="bi bi-x-circle me-1"></i> Hủy Đơn' +
                           '</button>';
        }

        if (status === 'ChoThanhToan') {
            actionsHtml += '<form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">' +
                           '  <input type="hidden" name="action" value="update-status">' +
                           '  <input type="hidden" name="id" value="' + orderId + '">' +
                           '  <input type="hidden" name="status" value="DangCheBien">' +
                           '  <button type="submit" class="btn btn-warning fw-bold py-2 px-3 shadow-sm text-dark" style="border-radius: 10px;"><i class="bi bi-fire me-1"></i> Bắt đầu Làm Món</button>' +
                           '</form>';
        } else if (status === 'DangCheBien') {
            actionsHtml += '<form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">' +
                           '  <input type="hidden" name="action" value="update-status">' +
                           '  <input type="hidden" name="id" value="' + orderId + '">' +
                           '  <input type="hidden" name="status" value="DaGiao">' +
                           '  <button type="submit" class="btn btn-primary fw-bold py-2 px-3" style="border-radius: 10px;"><i class="bi bi-check2-circle me-1"></i> Giao món</button>' +
                           '</form>';
        } else if (status === 'DaGiao') {
            actionsHtml += '<form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">' +
                           '  <input type="hidden" name="action" value="update-status">' +
                           '  <input type="hidden" name="id" value="' + orderId + '">' +
                           '  <input type="hidden" name="status" value="DaThanhToan">' +
                           '  <button type="submit" class="btn btn-success fw-bold py-2 px-3" style="border-radius: 10px;"><i class="bi bi-credit-card-2-back me-1"></i> Xác Nhận Thanh Toán</button>' +
                           '</form>';
        }
        actionContainer.innerHTML = actionsHtml;

        const modal = new bootstrap.Modal(document.getElementById('orderDetailModal'));
        modal.show();
    }

    // Hàm hiển thị Toast thông báo siêu tốc
    function showStaffToast(message, isError) {
        let container = document.getElementById("staffToastContainer");
        if (!container) {
            container = document.createElement("div");
            container.id = "staffToastContainer";
            container.className = "toast-container position-fixed bottom-0 end-0 p-3";
            container.style.zIndex = "1090";
            document.body.appendChild(container);
        }
        const toastEl = document.createElement("div");
        toastEl.className = `toast align-items-center text-white bg-${isError ? 'danger' : 'success'} border-0 show shadow-lg rounded-3 mb-2`;
        toastEl.setAttribute("role", "alert");
        toastEl.innerHTML = `
            <div class="d-flex">
                <div class="toast-body fs-6 py-2.5 px-3 fw-semibold">
                    <i class="bi bi-${isError ? 'exclamation-circle-fill' : 'check-circle-fill'} me-2"></i>\${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" onclick="this.closest('.toast').remove()"></button>
            </div>
        `;
        container.appendChild(toastEl);
        setTimeout(() => {
            toastEl.classList.remove("show");
            setTimeout(() => toastEl.remove(), 300);
        }, 3500);
    }

    // Hàm xử lý gửi form xác nhận đơn hàng mượt mà (Standard Form Submit)
    function submitStatusAjax(event, form) {
        const btn = form.querySelector('button[type="submit"]');
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status"></span> Đang xử lý...';
        }
        return true;
    }

    // Modal Xác Nhận Thanh Toán (Quick Payment)
    document.addEventListener("DOMContentLoaded", function() {
        const paymentModal = document.getElementById('paymentConfirmModal');
        if (paymentModal) {
            paymentModal.addEventListener('show.bs.modal', function (event) {
                const button = event.relatedTarget;
                if (!button) return;
                
                const id = button.getAttribute('data-id');
                const customerName = button.getAttribute('data-customer-name');
                const customerPhone = button.getAttribute('data-customer-phone');
                const staffName = button.getAttribute('data-staff-name');
                const totalAmount = button.getAttribute('data-total-amount');
                const items = button.getAttribute('data-items');

                document.getElementById('modalOrderId').value = id;
                document.getElementById('displayOrderId').innerText = '#' + id;
                document.getElementById('displayCustomerName').innerText = customerName || 'Khách vãng lai';
                document.getElementById('displayCustomerPhone').innerText = customerPhone || 'N/A';
                document.getElementById('displayStaffName').innerText = staffName || 'Chưa nhận';
                document.getElementById('displayTotalAmount').innerText = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(totalAmount).replace('₫', 'đ');
                
                const drinkItemsEl = document.getElementById('displayDrinkItems');
                if (drinkItemsEl) {
                    drinkItemsEl.innerText = items || 'Chi tiết đơn hàng';
                }
            });
        }
    });

    let currentStaffOffset = ${displayedCount != null ? displayedCount : 15};
    const initialStaffLimit = ${initialLimit != null ? initialLimit : 15};

    function loadMoreStaffOrders() {
        const btn = document.getElementById("btnLoadMoreStaffOrders");
        if (!btn) return;

        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Đang tải dữ liệu...';

        const url = '${pageContext.request.contextPath}/staff/orders?action=load-more&offset=' + currentStaffOffset + 
                    '&limit=' + initialStaffLimit + 
                    '&status=' + encodeURIComponent('${statusFilter}');

        fetch(url)
            .then(res => res.json())
            .then(data => {
                if (data && data.orders && data.orders.length > 0) {
                    const tbody = document.querySelector(".table tbody");
                    if (tbody) {
                        data.orders.forEach(o => {
                            const tr = document.createElement("tr");
                            tr.className = "align-middle";

                            let statusBadge = "";
                            if (o.status === 'ChoThanhToan') {
                                statusBadge = '<span class="badge bg-warning-subtle text-warning border px-2.5 py-1 rounded-pill"><i class="bi bi-hourglass-split me-1"></i>Chờ thanh toán</span>';
                            } else if (o.status === 'DangCheBien') {
                                statusBadge = '<span class="badge bg-info-subtle text-info border px-2.5 py-1 rounded-pill"><i class="bi bi-cup-hot-fill me-1"></i>Đang chế biến</span>';
                            } else if (o.status === 'DaGiao') {
                                statusBadge = '<span class="badge bg-primary-subtle text-primary border px-2.5 py-1 rounded-pill"><i class="bi bi-check2-circle me-1"></i>Đã giao món</span>';
                            } else if (o.status === 'DaThanhToan') {
                                statusBadge = '<span class="badge bg-success-subtle text-success border px-2.5 py-1 rounded-pill"><i class="bi bi-check-all me-1"></i>Đã thanh toán</span>';
                            } else if (o.status === 'DaHuy') {
                                statusBadge = '<span class="badge bg-danger-subtle text-danger border px-2.5 py-1 rounded-pill"><i class="bi bi-x-circle me-1"></i>Đã hủy</span>';
                            } else {
                                statusBadge = '<span class="badge bg-secondary-subtle text-secondary border px-2.5 py-1 rounded-pill">' + escapeHtmlStaff(o.status) + '</span>';
                            }

                            let locationBadge = "";
                            if (o.type === 'TaiCho') {
                                locationBadge = '<span class="badge bg-success-subtle text-success border rounded-pill px-2.5 py-1"><i class="bi bi-shop me-1"></i>' + escapeHtmlStaff(o.tableName) + '</span>';
                            } else {
                                locationBadge = '<span class="badge bg-warning-subtle text-warning border rounded-pill px-2.5 py-1"><i class="bi bi-bag-check me-1"></i>Mang Về</span>';
                            }

                            let actionBtnHtml = '';
                            if (o.status === 'DangCheBien') {
                                actionBtnHtml = 
                                    '<form action="${pageContext.request.contextPath}/staff/orders" method="post" class="m-0" onsubmit="return submitStatusAjax(event, this)">' +
                                        '<input type="hidden" name="action" value="update-status">' +
                                        '<input type="hidden" name="id" value="' + o.id + '">' +
                                        '<input type="hidden" name="status" value="DaGiao">' +
                                        '<button type="submit" class="btn btn-sm btn-primary px-3 py-1.5 fw-bold" style="border-radius: 8px;">' +
                                            '<i class="bi bi-check2-circle me-1"></i> Giao món' +
                                        '</button>' +
                                    '</form>';
                            } else if (o.status === 'DaGiao') {
                                actionBtnHtml = 
                                    '<button type="button" class="btn btn-sm btn-success px-3 py-1.5 fw-bold" style="border-radius: 8px;"' +
                                            ' data-bs-toggle="modal"' + 
                                            ' data-bs-target="#paymentConfirmModal"' +
                                            ' data-id="' + o.id + '"' +
                                            ' data-customer-name="' + escapeHtmlStaff(o.customerName) + '"' +
                                            ' data-customer-phone="' + escapeHtmlStaff(o.customerPhone) + '"' +
                                            ' data-staff-name="' + escapeHtmlStaff(o.staffName) + '"' +
                                            ' data-total-amount="' + o.total + '"' +
                                            ' data-items="' + escapeHtmlStaff(o.itemsSummary || '') + '">' +
                                        '<i class="bi bi-currency-dollar me-1"></i> Thanh toán' +
                                    '</button>';
                            }

                            tr.innerHTML = 
                                '<td><strong class="text-dark">#' + o.id + '</strong></td>' +
                                '<td><span class="text-muted" style="font-size: 0.9rem;">' + escapeHtmlStaff(o.dateStr) + '</span></td>' +
                                '<td>' + locationBadge + '</td>' +
                                '<td>' +
                                    '<div class="fw-semibold text-dark">' + escapeHtmlStaff(o.customerName) + '</div>' +
                                    (o.customerPhone ? '<small class="text-muted d-block" style="font-size: 0.78rem;"><i class="bi bi-telephone me-1"></i>' + escapeHtmlStaff(o.customerPhone) + '</small>' : '') +
                                '</td>' +
                                '<td class="text-end fw-bold text-dark">' + o.formattedTotal + '</td>' +
                                '<td>' +
                                    '<span class="text-secondary" style="font-size: 0.95rem;">' +
                                        '<i class="bi bi-person-badge me-1"></i>' + escapeHtmlStaff(o.staffName) +
                                    '</span>' +
                                '</td>' +
                                '<td class="text-center">' + statusBadge + '</td>' +
                                '<td class="text-center">' +
                                    '<div class="d-flex justify-content-center align-items-center gap-1">' +
                                        '<button type="button" class="btn btn-sm btn-outline-secondary px-3 py-1.5" style="border-radius: 8px;" onclick="showOrderDetailModal(' + o.id + ')">' +
                                            '<i class="bi bi-eye-fill"></i> Chi Tiết' +
                                        '</button>' +
                                        '<div id="order-data-' + o.id + '" class="d-none"' +
                                             ' data-id="' + o.id + '"' +
                                             ' data-date="' + escapeHtmlStaff(o.dateStr) + '"' +
                                             ' data-location="' + escapeHtmlStaff(o.type === 'TaiCho' ? o.tableName : 'Mang về') + '"' +
                                             ' data-customer-name="' + escapeHtmlStaff(o.customerName) + '"' +
                                             ' data-customer-phone="' + escapeHtmlStaff(o.customerPhone) + '"' +
                                             ' data-staff-name="' + escapeHtmlStaff(o.staffName) + '"' +
                                             ' data-formatted-total="' + escapeHtmlStaff(o.formattedTotal) + '"' +
                                             ' data-total="' + o.total + '"' +
                                             ' data-status="' + escapeHtmlStaff(o.status) + '"' +
                                             ' data-type="' + escapeHtmlStaff(o.type) + '"' +
                                             ' data-note="' + escapeHtmlStaff(o.note) + '">' +
                                            '<div class="items-list">' + (o.itemsHtml || '') + '</div>' +
                                        '</div>' +
                                        actionBtnHtml +
                                    '</div>' +
                                '</td>';
                            tbody.appendChild(tr);
                        });

                        currentStaffOffset = data.loadedCount;
                        const displayedEl = document.getElementById("displayedStaffCount");
                        if (displayedEl) displayedEl.innerText = currentStaffOffset;

                        if (!data.hasMore) {
                            const container = document.getElementById("loadMoreStaffOrderContainer");
                            if (container) container.style.display = "none";
                        }
                    }
                } else {
                    const container = document.getElementById("loadMoreStaffOrderContainer");
                    if (container) container.style.display = "none";
                }
            })
            .catch(err => {
                console.error("Error loading more staff orders:", err);
            })
            .finally(() => {
                btn.disabled = false;
                btn.innerHTML = '<i class="bi bi-arrow-down-circle me-1"></i> Xem Thêm Đơn Hàng';
            });
    }

    function escapeHtmlStaff(str) {
        if (!str) return '';
        return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }
</script>

<jsp:include page="common/staff-footer.jsp" />
