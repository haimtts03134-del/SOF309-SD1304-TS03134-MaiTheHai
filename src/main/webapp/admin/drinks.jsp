<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!-- Nhúng Header dùng chung -->
<jsp:include page="common/header.jsp" />

<style>
    .preset-img-card {
        transition: all 0.2s ease-in-out;
        cursor: pointer;
    }
    .preset-img-card:hover {
        transform: translateY(-2px);
        border-color: #8c6239 !important;
        box-shadow: 0 4px 10px rgba(140, 98, 57, 0.2);
    }
</style>

<div class="container-fluid px-0">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="fw-bold text-dark"><i class="bi bi-cup-hot-fill text-warning me-2"></i>Quản Lý Thực Đơn Nước Uống</h2>
            <p class="text-muted">Xem danh sách, thêm mới, tải ảnh .jpg từ máy tính hoặc chọn ảnh mẫu từ thư mục images.</p>
        </div>
    </div>

    <div class="row g-4">
        <!-- Cột Danh sách đồ uống (Chiếm 8 phần cột trên màn hình lớn) -->
        <div class="col-12 col-lg-8">
            <div class="custom-card shadow-sm border-0" style="border-radius: 14px;">
                <div class="card-title-container d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                    <h5 class="custom-card-title fw-bold text-dark mb-0"><i class="bi bi-list-stars me-2 text-warning"></i>Danh Sách Đồ Uống</h5>
                    <span class="badge bg-secondary-subtle text-dark border">${drinks.size()} món</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table custom-table align-middle">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Hình Ảnh</th>
                                <th>Tên Món</th>
                                <th>Danh Mục</th>
                                <th class="text-end">Giá Cơ Bản</th>
                                <th class="text-center">Trạng Thái</th>
                                <th class="text-center" style="width: 100px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="drink" items="${drinks}">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty drink.hinhAnh}">
                                                <c:set var="imgUrl" value="${drink.hinhAnh}" />
                                                <c:if test="${!drink.hinhAnh.startsWith('http') && !drink.hinhAnh.startsWith('data:') && !drink.hinhAnh.startsWith('/')}">
                                                    <c:set var="imgUrl" value="${pageContext.request.contextPath}/admin/images/${drink.hinhAnh}" />
                                                </c:if>
                                                <img src="${imgUrl}" class="rounded border shadow-sm" 
                                                     style="width: 60px; height: 60px; object-fit: cover;" 
                                                     alt="${drink.tenSanPham}"
                                                     onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${drink.hinhAnh}'; if(this.naturalWidth===0){this.src='https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500';}">
                                            </c:when>
                                            <c:otherwise>
                                                <div class="rounded border bg-light text-muted d-flex align-items-center justify-content-center shadow-sm" style="width: 60px; height: 60px;">
                                                    <i class="bi bi-cup-hot fs-4"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${drink.tenSanPham}</div>
                                        <div class="text-muted text-truncate" style="max-width: 200px; font-size: 0.85rem;" title="${drink.moTa}">
                                            ${not empty drink.moTa ? drink.moTa : 'Chưa có mô tả'}
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border rounded-pill">${drink.category.tenDanhMuc}</span>
                                    </td>
                                    <td class="text-end fw-semibold text-success">
                                        <fmt:formatNumber value="${drink.giaCoBan}" type="currency" currencySymbol="đ" maxFractionDigits="0" />
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${drink.trangThai == 'DangBan'}">
                                                <span class="badge-active"><i class="bi bi-check-circle-fill me-1"></i>Đang bán</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-inactive"><i class="bi bi-x-circle-fill me-1"></i>Ngừng bán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <!-- Nút sửa món -->
                                        <a href="${pageContext.request.contextPath}/admin/drinks?action=edit&id=${drink.maSanPham}" 
                                           class="btn btn-sm btn-outline-warning action-btn" title="Chỉnh sửa thông tin & ảnh">
                                            <i class="bi bi-pencil-square"></i>
                                        </a>
                                        <!-- Nút xóa món -->
                                        <a href="${pageContext.request.contextPath}/admin/drinks?action=delete&id=${drink.maSanPham}" 
                                           class="btn btn-sm btn-outline-danger action-btn" title="Xóa"
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa món nước \'${drink.tenSanPham}\' này không?');">
                                            <i class="bi bi-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty drinks}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-inbox fs-1 d-block mb-3"></i>
                                        Chưa có đồ uống nào trong cơ sở dữ liệu. Hãy thêm món mới bên cạnh!
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Cột Form thêm / cập nhật đồ uống & Chỉnh sửa ảnh -->
        <div class="col-12 col-lg-4">
            <div class="form-card shadow-sm border-0" style="border-radius: 14px;">
                <h5 class="fw-bold mb-4 border-bottom pb-2 text-dark">
                    <c:choose>
                        <c:when test="${isEdit}">
                            <i class="bi bi-pencil-square text-warning me-2"></i>Cập Nhật Đồ Uống & Ảnh .JPG
                        </c:when>
                        <c:otherwise>
                            <i class="bi bi-plus-circle-fill text-success me-2"></i>Thêm Món Nước Mới
                        </c:otherwise>
                    </c:choose>
                </h5>

                <form action="${pageContext.request.contextPath}/admin/drinks" method="post">
                    <!-- Truyền ID và Hành động tương ứng -->
                    <c:choose>
                        <c:when test="${isEdit}">
                            <input type="hidden" name="action" value="update">
                            <input type="hidden" name="id" value="${selectedDrink.maSanPham}">
                        </c:when>
                        <c:otherwise>
                            <input type="hidden" name="action" value="insert">
                        </c:otherwise>
                    </c:choose>

                    <!-- Tên sản phẩm -->
                    <div class="mb-3">
                        <label for="tenSanPham" class="form-label fw-semibold">Tên món nước <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="tenSanPham" name="tenSanPham" 
                               placeholder="Ví dụ: Cà Phê Sữa Đá" value="${selectedDrink.tenSanPham}" required>
                    </div>

                    <!-- Danh mục sản phẩm -->
                    <div class="mb-3">
                        <label for="maDanhMuc" class="form-label fw-semibold">Danh mục thực đơn <span class="text-danger">*</span></label>
                        <select class="form-select" id="maDanhMuc" name="maDanhMuc" required>
                            <option value="" disabled ${empty selectedDrink ? 'selected' : ''}>-- Chọn danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.maDanhMuc}" ${selectedDrink.category.maDanhMuc == cat.maDanhMuc ? 'selected' : ''}>
                                    ${cat.tenDanhMuc}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Giá cơ bản -->
                    <div class="mb-3">
                        <label for="giaCoBan" class="form-label fw-semibold">Giá cơ bản (đ) <span class="text-danger">*</span></label>
                        <input type="number" class="form-control" id="giaCoBan" name="giaCoBan" min="0" step="500"
                               placeholder="Ví dụ: 29000" value="${isEdit ? String.format('%.0f', selectedDrink.giaCoBan) : ''}" required>
                    </div>

                    <!-- CHỈNH SỬA & CHỌN ẢNH LY COFFEE -->
                    <div class="mb-3">
                        <label for="hinhAnh" class="form-label fw-semibold">
                            <i class="bi bi-image text-warning me-1"></i>Hình ảnh ly Coffee / Đồ uống (.JPG, .PNG)
                        </label>

                        <!-- Khung xem trước ảnh trực tiếp -->
                        <div class="text-center p-2 mb-2 bg-light rounded border">
                            <c:set var="previewSrc" value="https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500" />
                            <c:if test="${not empty selectedDrink.hinhAnh}">
                                <c:choose>
                                    <c:when test="${selectedDrink.hinhAnh.startsWith('http') || selectedDrink.hinhAnh.startsWith('data:') || selectedDrink.hinhAnh.startsWith('/')}">
                                        <c:set var="previewSrc" value="${selectedDrink.hinhAnh}" />
                                    </c:when>
                                    <c:otherwise>
                                        <c:set var="previewSrc" value="${pageContext.request.contextPath}/admin/images/${selectedDrink.hinhAnh}" />
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <img id="drinkImagePreview" src="${previewSrc}" class="rounded border shadow-sm mb-1" 
                                 style="height: 120px; width: 120px; object-fit: cover;" 
                                 alt="Xem trước ảnh món" 
                                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/${selectedDrink.hinhAnh}'; if(this.naturalWidth===0){this.src='https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500';}">
                            <small class="d-block text-muted" style="font-size: 0.78rem;">Hình ảnh sẽ hiển thị trên thực đơn khách & trang nhân viên</small>
                        </div>

                        <!-- 1. Tải ảnh từ máy tính (Upload file ảnh .jpg) -->
                        <div class="mb-2">
                            <label class="form-label small text-secondary fw-semibold mb-1">
                                <i class="bi bi-upload me-1 text-primary"></i>1. Tải ảnh từ máy tính (.jpg, .png, .jpeg):
                            </label>
                            <input type="file" id="imageFileInput" accept="image/*" class="form-control form-control-sm" onchange="handleFileUpload(this)">
                        </div>

                        <!-- 2. Ô nhập tên file trong thư mục images/ hoặc URL ảnh -->
                        <div class="mb-2">
                            <label class="form-label small text-secondary fw-semibold mb-1">
                                <i class="bi bi-link-45deg me-1 text-primary"></i>2. Hoặc nhập tên file trong images/ hay dán URL:
                            </label>
                            <input type="text" class="form-control form-control-sm" id="hinhAnh" name="hinhAnh" 
                                   placeholder="VD: caphasua.jpg, caphe_den.jpg, caphe_sua_da.png" 
                                   value="${selectedDrink.hinhAnh}" oninput="updateImagePreview(this.value)">
                        </div>

                        <!-- 3. Bộ sưu tập chọn nhanh các mẫu ảnh ly coffee (.jpg & .png) -->
                        <label class="form-label small text-secondary fw-semibold mb-1">
                            <i class="bi bi-grid-fill me-1 text-warning"></i>3. Hoặc chọn nhanh ảnh mẫu có sẵn (.jpg & .png):
                        </label>
                        <div class="d-flex flex-wrap gap-2 p-2 bg-light rounded border" style="max-height: 160px; overflow-y: auto;">
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('caphasua.jpg')" 
                                 title="Cà phê sữa (caphasua.jpg)">
                                <img src="${pageContext.request.contextPath}/admin/images/caphasua.jpg" class="rounded" style="width: 46px; height: 46px; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/images/caphasua.jpg'">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">caphasua.jpg</small>
                            </div>
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('caphe_den.jpg')" 
                                 title="Cà phê đen (.jpg local)">
                                <img src="${pageContext.request.contextPath}/admin/images/caphe_den.jpg" class="rounded" style="width: 46px; height: 46px; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/images/caphe_den.jpg'">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">caphe_den.jpg</small>
                            </div>
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('caphe_sua_da.jpg')" 
                                 title="Cà phê sữa đá (.jpg local)">
                                <img src="${pageContext.request.contextPath}/admin/images/caphe_sua_da.jpg" class="rounded" style="width: 46px; height: 46px; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/images/caphe_sua_da.jpg'">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">caphe_sua.jpg</small>
                            </div>
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('tra_sua.jpg')" 
                                 title="Trà sữa (.jpg local)">
                                <img src="${pageContext.request.contextPath}/admin/images/tra_sua.jpg" class="rounded" style="width: 46px; height: 46px; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/images/tra_sua.jpg'">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">tra_sua.jpg</small>
                            </div>
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('tra_dao.jpg')" 
                                 title="Trà đào (.jpg local)">
                                <img src="${pageContext.request.contextPath}/admin/images/tra_dao.jpg" class="rounded" style="width: 46px; height: 46px; object-fit: cover;" onerror="this.src='${pageContext.request.contextPath}/images/tra_dao.jpg'">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">tra_dao.jpg</small>
                            </div>
                            <div class="preset-img-card text-center border rounded bg-white p-1" 
                                 onclick="selectPresetImage('caphe_sua_da.png')" 
                                 title="Cà phê sữa đá (.png local)">
                                <img src="${pageContext.request.contextPath}/admin/images/caphe_sua_da.png" class="rounded" style="width: 46px; height: 46px; object-fit: cover;">
                                <small class="d-block text-truncate fw-semibold mt-1" style="max-width: 58px; font-size: 0.68rem;">caphe_sua.png</small>
                            </div>
                        </div>
                    </div>

                    <!-- Trạng thái bán -->
                    <div class="mb-3">
                        <label for="trangThai" class="form-label fw-semibold">Trạng thái bán</label>
                        <select class="form-select" id="trangThai" name="trangThai">
                            <option value="DangBan" ${selectedDrink.trangThai == 'DangBan' ? 'selected' : ''}>Đang bán</option>
                            <option value="NgungBan" ${selectedDrink.trangThai == 'NgungBan' ? 'selected' : ''}>Ngừng bán</option>
                        </select>
                    </div>

                    <!-- Mô tả sản phẩm -->
                    <div class="mb-4">
                        <label for="moTa" class="form-label fw-semibold">Mô tả sản phẩm</label>
                        <textarea class="form-control" id="moTa" name="moTa" rows="3" 
                                  placeholder="Mô tả nguyên liệu, hương vị món...">${selectedDrink.moTa}</textarea>
                    </div>

                    <!-- Nút gửi -->
                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-coffee flex-grow-1 py-2 fw-bold">
                            <i class="bi bi-cloud-arrow-up-fill me-2"></i>Lưu thông tin món
                        </button>
                        <c:if test="${isEdit}">
                            <a href="${pageContext.request.contextPath}/admin/drinks" class="btn btn-outline-secondary py-2">
                                Hủy
                            </a>
                        </c:if>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function handleFileUpload(input) {
        if (input.files && input.files[0]) {
            const file = input.files[0];
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = new Image();
                img.onload = function() {
                    const canvas = document.createElement('canvas');
                    let width = img.width;
                    let height = img.height;
                    const maxDim = 600; // Tối đa 600px

                    if (width > maxDim || height > maxDim) {
                        if (width > height) {
                            height = Math.round((height * maxDim) / width);
                            width = maxDim;
                        } else {
                            width = Math.round((width * maxDim) / height);
                            height = maxDim;
                        }
                    }

                    canvas.width = width;
                    canvas.height = height;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0, width, height);

                    const compressedDataUrl = canvas.toDataURL('image/jpeg', 0.85);
                    document.getElementById('hinhAnh').value = compressedDataUrl;
                    updateImagePreview(compressedDataUrl);
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }

    function selectPresetImage(url) {
        document.getElementById('hinhAnh').value = url;
        updateImagePreview(url);
    }

    function updateImagePreview(val) {
        const preview = document.getElementById('drinkImagePreview');
        if (!preview) return;
        if (!val || val.trim() === '') {
            preview.src = 'https://images.unsplash.com/photo-1541167760496-1628856ab772?w=500';
        } else if (val.startsWith('http') || val.startsWith('data:') || val.startsWith('/')) {
            preview.src = val;
        } else {
            preview.src = '${pageContext.request.contextPath}/admin/images/' + val;
        }
    }
</script>

<!-- Nhúng Footer dùng chung -->
<jsp:include page="common/footer.jsp" />
