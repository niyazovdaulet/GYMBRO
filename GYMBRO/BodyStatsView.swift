import SwiftUI

struct BodyStatsView: View {
    @StateObject private var viewModel = BodyStatsViewModel()
    @State private var showingAddMeasurement = false
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case allTime = "All Time"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Selector
                    timeRangeSelector
                    
                    // Current Measurements
                    currentMeasurementsSection
                    
                    // Progress Charts
                    progressChartsSection
                    
                    // Measurement History
                    measurementHistorySection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
            }
            .background(Color.undergroundPrimary)
            .navigationTitle("Body Stats")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddMeasurement = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.undergroundAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddMeasurement) {
                AddMeasurementView { measurement in
                    viewModel.addMeasurement(measurement)
                    showingAddMeasurement = false
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadData()
                }
            }
        }
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        VStack(spacing: 16) {
            Text("Time Range")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        selectedTimeRange = range
                        Task {
                            await viewModel.loadDataForTimeRange(range)
                        }
                    }) {
                        Text(range.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTimeRange == range ? Color.undergroundPrimary : Color.undergroundText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTimeRange == range ? Color.undergroundAccent : Color.undergroundCard)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.undergroundBorder, lineWidth: 1)
                            )
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Current Measurements Section
    private var currentMeasurementsSection: some View {
        VStack(spacing: 16) {
            Text("Current Measurements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                BodyStatCard(
                    title: "Weight",
                    value: String(format: "%.1f", viewModel.currentWeight),
                    unit: "lbs",
                    icon: "scalemass.fill",
                    color: Color.undergroundAccent,
                    change: viewModel.weightChange,
                    isPositive: viewModel.weightChange > 0
                )
                
                BodyStatCard(
                    title: "Body Fat %",
                    value: String(format: "%.1f", viewModel.currentBodyFat),
                    unit: "%",
                    icon: "person.fill",
                    color: Color.undergroundAccentSecondary,
                    change: viewModel.bodyFatChange,
                    isPositive: viewModel.bodyFatChange < 0
                )
                
                BodyStatCard(
                    title: "Muscle Mass",
                    value: String(format: "%.1f", viewModel.currentMuscleMass),
                    unit: "lbs",
                    icon: "figure.strengthtraining.traditional",
                    color: Color.undergroundAccentTertiary,
                    change: viewModel.muscleMassChange,
                    isPositive: viewModel.muscleMassChange > 0
                )
                
                BodyStatCard(
                    title: "BMI",
                    value: String(format: "%.1f", viewModel.currentBMI),
                    unit: "",
                    icon: "chart.bar.fill",
                    color: Color.undergroundAccent,
                    change: viewModel.bmiChange,
                    isPositive: viewModel.bmiChange < 0
                )
            }
        }
    }
    
    // MARK: - Progress Charts Section
    private var progressChartsSection: some View {
        VStack(spacing: 16) {
            Text("Progress Charts")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !viewModel.measurementHistory.isEmpty {
                VStack(spacing: 20) {
                    // Weight Progress Chart
                    ProgressChartCard(
                        title: "Weight Progress",
                        data: viewModel.weightProgressData,
                        color: Color.undergroundAccent,
                        unit: "lbs"
                    )
                    
                    // Body Fat Progress Chart
                    ProgressChartCard(
                        title: "Body Fat Progress",
                        data: viewModel.bodyFatProgressData,
                        color: Color.undergroundAccentSecondary,
                        unit: "%"
                    )
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No measurement data yet")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Add your first measurement to see progress charts!")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .background(Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundBorder, lineWidth: 1)
                )
            }
        }
    }
    
    // MARK: - Measurement History Section
    private var measurementHistorySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Measurement History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.undergroundText)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to full history
                }
                .font(.subheadline)
                .foregroundColor(Color.undergroundAccent)
            }
            
            if !viewModel.measurementHistory.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.measurementHistory.prefix(5)) { measurement in
                        MeasurementHistoryRow(measurement: measurement)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 40))
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("No measurements yet")
                        .font(.subheadline)
                        .foregroundColor(Color.undergroundTextSecondary)
                    
                    Text("Start tracking your body stats to see history here!")
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                .background(Color.undergroundCard)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.undergroundBorder, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct BodyStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let change: Double
    let isPositive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                if change != 0 {
                    HStack(spacing: 4) {
                        Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                            .font(.caption)
                            .foregroundColor(isPositive ? Color.green : Color.red)
                        
                        Text(String(format: "%.1f", abs(change)))
                            .font(.caption)
                            .foregroundColor(isPositive ? Color.green : Color.red)
                    }
                }
            }
            
            VStack(spacing: 4) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.undergroundText)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(Color.undergroundTextSecondary)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

struct ProgressChartCard: View {
    let title: String
    let data: [BodyProgressDataPoint]
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.undergroundText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !data.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(data.suffix(14)) { point in
                        VStack(spacing: 4) {
                            Rectangle()
                                .fill(color)
                                .frame(width: 20, height: max(4, CGFloat(point.value / maxValue) * 80))
                                .cornerRadius(2)
                            
                            Text(DateFormatter.dayFormatter.string(from: point.date))
                                .font(.caption2)
                                .foregroundColor(Color.undergroundTextMuted)
                                .rotationEffect(.degrees(-45))
                        }
                    }
                }
                .frame(height: 120)
                .padding(.horizontal)
                
                Text("Progress Over Time")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
        }
        .padding(20)
        .background(Color.undergroundCard)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
}

struct MeasurementHistoryRow: View {
    let measurement: BodyMeasurement
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(DateFormatter.monthDayFormatter.string(from: measurement.date))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundAccent)
                
                Text(DateFormatter.timeFormatter.string(from: measurement.date))
                    .font(.caption2)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Body Measurement")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.undergroundText)
                
                Text("Weight: \(String(format: "%.1f", measurement.weight)) lbs • Body Fat: \(String(format: "%.1f", measurement.bodyFat))%")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("BMI: \(String(format: "%.1f", measurement.bmi))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.undergroundAccent)
                
                Text("Muscle: \(String(format: "%.1f", measurement.muscleMass)) lbs")
                    .font(.caption)
                    .foregroundColor(Color.undergroundTextSecondary)
            }
        }
        .padding(16)
        .background(Color.undergroundCard)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.undergroundBorder, lineWidth: 1)
        )
    }
}

#Preview {
    BodyStatsView()
}
