import SwiftUI
import Charts
import FirebaseAuth

struct SellerHomeView: View {
    @StateObject private var vm = SellerViewModel()
    @EnvironmentObject private var coordinator: Coordinator

    @State private var headerVisible = false
    @State private var dashboardVisible = false
    @State private var showMenu = false
    @State private var showAboutSheet = false
    @State private var showHelpSheet = false

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let pageBg = Color(red: 0.95, green: 0.97, blue: 0.95)
    let menuWidth: CGFloat = 280

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {
                topNavigationBar
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : -20)

                    ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        headerSection
                        statsGrid
                        financeChartSection
                        categorySalesSection
                        reviewsSection
                        addProductButton
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                    .opacity(dashboardVisible ? 1 : 0)
                    .offset(y: dashboardVisible ? 0 : 30)
                }
            }

            if showMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { closeMenu() }

                HStack {
                    sellerDrawer
                        .frame(width: UIScreen.main.bounds.width * 0.75)
                        .background(Color.white)
                        .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width * 0.25)
                        .animation(.easeInOut(duration: 0.7), value: showMenu)
                    Spacer()
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAboutSheet) { AboutView() }
        .sheet(isPresented: $showHelpSheet) { HelpView() }
        .task { await vm.loadDashboard() }
        .refreshable { await vm.loadDashboard() }
        .onAppear {
            animateEntrance()
            Task { await vm.loadDashboard() }
        }
        .overlay(alignment: .bottom) {
            if let msg = vm.toastMessage {
                Text(msg)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(brandGreen.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { vm.toastMessage = nil }
                        }
                    }
            }
        }
        .animation(.spring(), value: vm.toastMessage != nil)
    }

    private func closeMenu() {
        withAnimation(.easeInOut(duration: 0.25)) { showMenu = false }
    }

    private var topNavigationBar: some View {
        HStack(spacing: 12) {
            Button(action: { withAnimation(.easeInOut) { showMenu = true } }) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white)
                            .frame(width: 22, height: 2.5)
                    }
                }
            }

            Text("Agri BD")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .padding(.top, 4)
        .background(brandGreen.ignoresSafeArea(edges: .top))
    }

    private var sellerDrawer: some View {
        ZStack(alignment: .top) {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                        Image(systemName: "briefcase.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(brandGreen)
                            .frame(width: 35, height: 35)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 10)

                    Text(vm.userName.isEmpty ? "Seller" : vm.userName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Seller Dashboard")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(brandGreen)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 5) {
                            drawerItem(icon: "cart.fill", title: "Agri Market")
                            drawerItem(icon: "bag.fill", title: "Products")
                            drawerItem(icon: "chart.bar.fill", title: "Sales by Category")
                            drawerItem(icon: "star.fill", title: "Reviews")
                        }

                        Divider()
                            .padding(.vertical, 15)
                            .padding(.horizontal, 20)

                        VStack(alignment: .leading, spacing: 5) {
                            drawerItem(icon: "character.book.closed.fill", title: "Change Language")
                            drawerItem(icon: "questionmark.circle.fill", title: "Help")
                            drawerItem(icon: "info.circle.fill", title: "About")
                        }

                        Button {
                            do { try AuthManager.shared.logout() } catch { }
                        } label: {
                            HStack(spacing: 20) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                Text("Logout")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .padding(.bottom, 100)
                        Spacer()
                    }
                }
                .background(pageBg)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }

    private func drawerItem(icon: String, title: String) -> some View {
        Button(action: { closeMenu() }) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(brandGreen)
                    .frame(width: 30)
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 0.4)) { headerVisible = true }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.15)) { dashboardVisible = true }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Seller Dashboard")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            Text(vm.userName.isEmpty ? "Seller" : vm.userName)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(brandGreen)
            HStack {
                Image(systemName: "taka.sign.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(brandGreen)
                Text("\("Balance:") ৳\(String(format: "%.2f", vm.userBalance))")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(brandGreen)
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            NavigationLink(destination: SellerProductListView(vm: vm)) {
                statCard(title: "Products", value: "\(vm.totalProducts)", icon: "bag.fill", color: brandGreen)
            }
            .buttonStyle(.plain)
            NavigationLink(destination: SellerOrderListView(vm: vm)) {
                statCard(title: "Orders", value: "\(vm.totalOrders)", icon: "shippingbox.fill", color: .blue)
            }
            .buttonStyle(.plain)
            statCard(title: "Earned", value: "৳\(String(format: "%.0f", vm.totalEarned))", icon: "taka.sign.circle.fill", color: .orange)
            statCard(title: "Reviews", value: "\(vm.reviewCount)", icon: "star.fill", color: .yellow)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private var financeChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 16))
                    .foregroundColor(brandGreen)
                Text("Finance Overview")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            VStack(spacing: 10) {
                financeRow(label: "Earned", value: vm.totalEarned, color: .green)
                financeRow(label: "Current Balance", value: vm.userBalance, color: brandGreen)
                financeRow(label: "Withdrawn/Spent", value: vm.totalEarned - vm.userBalance, color: .orange)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        }
    }

    private func financeRow(label: String, value: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Spacer()
            Text("৳\(String(format: "%.2f", value))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
        }
    }

    private var categorySalesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundColor(brandGreen)
                Text("Sales by Category")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
            }

            if vm.categorySales.isEmpty {
                Text("No sales data yet")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Chart(vm.categorySales, id: \.0) { cat, amount in
                    BarMark(
                        x: .value("Category", categoryLabel(cat)),
                        y: .value("Sales", amount)
                    )
                    .foregroundStyle(by: .value("Category", categoryLabel(cat)))
                }
                .chartLegend(.hidden)
                .frame(height: 180)
                .padding(14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                Text("Reviews")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                if vm.reviewCount > 0 {
                    HStack(spacing: 2) {
                        Text(String(format: "%.1f", vm.averageRating))
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                    }
                }
            }

            if vm.reviews.isEmpty {
                Text("No reviews yet")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                ForEach(vm.reviews.prefix(5)) { review in
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { i in
                                    Image(systemName: i <= review.rating ? "star.fill" : "star")
                                        .font(.system(size: 9))
                                        .foregroundColor(.yellow)
                                }
                            }
                            Text(review.comment)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                            Text(review.farmerName)
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var addProductButton: some View {
        NavigationLink(destination: AgriMarketView()) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                Text("Add New Product")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(brandGreen)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func categoryLabel(_ raw: String) -> String {
        switch raw {
        case "plant": return "Plants & Seeds"
        case "medicine": return "Medicines"
        case "fertilizer": return "Fertilizers"
        case "equipment": return "Equipment"
        default: return raw
        }
    }
}

struct SellerProductListView: View {
    @ObservedObject var vm: SellerViewModel

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let pageBg = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.myProducts.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "bag")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No products yet")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                } else {
                    ForEach(vm.myProducts) { product in
                        if vm.editingProductId == product.id {
                            editProductCard(product)
                        } else {
                            productCard(product)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(pageBg.ignoresSafeArea())
        .navigationTitle("My Products")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func productCard(_ product: MarketProduct) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: product.category.color).opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: product.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: product.category.color))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    HStack(spacing: 6) {
                        Text("৳\(String(format: "%.0f", product.price))")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(brandGreen)
                        Text("·")
                            .foregroundColor(.secondary)
                        Text("Qty: \(product.quantity)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(action: { vm.beginEdit(product) }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(brandGreen)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private func editProductCard(_ product: MarketProduct) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text("Edit Product")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(brandGreen)
                Spacer()
                Button(action: { vm.cancelEdit() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                }
            }

            VStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                    TextField("Product name", text: $vm.editName)
                        .font(.system(size: 14))
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Price (৳)").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                        TextField("Price", text: $vm.editPrice)
                            .font(.system(size: 14))
                            .keyboardType(.decimalPad)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                        TextField("Qty", text: $vm.editQuantity)
                            .font(.system(size: 14))
                            .keyboardType(.numberPad)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Description").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)
                    TextField("Description", text: $vm.editDescription)
                        .font(.system(size: 14))
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }

            Button(action: { vm.saveEdit(for: product.id) }) {
                Text("Save Changes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}

struct SellerOrderListView: View {
    @ObservedObject var vm: SellerViewModel

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let pageBg = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                if vm.orders.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No orders yet")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(40)
                } else {
                    ForEach(vm.orders) { order in
                        NavigationLink(destination: SellerOrderDetailView(order: order)) {
                            orderCard(order)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background(pageBg.ignoresSafeArea())
        .navigationTitle("Orders")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func orderCard(_ order: MarketOrder) -> some View {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let myItems = order.items.filter { $0.sellerId == uid }
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                Text(order.farmerName)
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(order.status.capitalized)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor(order.status))
                    .clipShape(Capsule())
            }

            ForEach(myItems, id: \.productId) { item in
                HStack {
                    Text(item.productName)
                        .font(.system(size: 12))
                    Spacer()
                    Text("\(item.quantity)× ৳\(String(format: "%.0f", item.price))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(brandGreen)
                }
            }

            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text("\(order.address.street), \(order.address.city), \(order.address.district)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Text(order.createdAt, style: .date)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "shipped": return .blue
        case "delivered": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}

struct SellerOrderDetailView: View {
    let order: MarketOrder

    private let brandGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    private let pageBg = Color(red: 0.95, green: 0.97, blue: 0.95)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                orderHeader
                addressSection
                itemsSection
                summarySection
            }
            .padding(20)
        }
        .background(pageBg.ignoresSafeArea())
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var orderHeader: some View {
        VStack(spacing: 4) {
            Text(order.farmerName)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            Text(order.status.capitalized)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor(order.status))
                .clipShape(Capsule())
            Text(order.createdAt, style: .date)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                Text("Delivery Address")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }
            Text("\(order.address.street), \(order.address.city), \(order.address.district)")
                .font(.system(size: 13))
                .foregroundColor(.primary)
            Text(order.address.phone)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shippingbox.fill")
                    .foregroundColor(.blue)
                Text("Items")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
                Spacer()
                Text("\(order.items.count) item(s)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            ForEach(order.items, id: \.productId) { item in
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.productName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Seller: \(item.sellerName)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(item.quantity)× ৳\(String(format: "%.0f", item.price))")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(brandGreen)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private var summarySection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Total")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                Spacer()
                Text("৳\(String(format: "%.2f", order.total))")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(brandGreen)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "shipped": return .blue
        case "delivered": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}
