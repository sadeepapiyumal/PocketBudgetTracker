
//  OnboardingView.swift

//  Introduces key features: expense tracking, analytics visualization, and AI predictions.

import SwiftUI

// Multi-page onboarding flow introducing app features to new users.
struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Page 0: Welcome screen with app branding
                WelcomePageView(
                    currentPage: $currentPage
                )
                .tag(0)
                
                // Page 1: Expense tracking feature
                OnboardingPageView(
                    iconName: "creditcard",
                    title: "Track Every Expense",
                    description: "Record your income and expenses effortlessly.",
                    currentPage: $currentPage,
                    totalPages: 4,
                    isLastPage: false
                )
                .tag(1)
                
                // Page 2: Analytics visualization feature
                OnboardingPageView(
                    iconName: "chart.bar.xaxis",
                    title: "Visualize Your Spending",
                    description: "View insightful charts and spending patterns.",
                    currentPage: $currentPage,
                    totalPages: 4,
                    isLastPage: false
                )
                .tag(2)
                
                // Page 3: AI prediction feature (final page)
                OnboardingPageView(
                    iconName: "brain.head.profile",
                    title: "Predict Smarter",
                    description: "Use AI-powered predictions to plan your future expenses.",
                    currentPage: $currentPage,
                    totalPages: 4,
                    isLastPage: true,
                    onComplete: {
                        showOnboarding = false
                    }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - WelcomePageView
struct WelcomePageView: View {
    // MARK: - Properties
    @Binding var currentPage: Int
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // App logo/icon
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.bottom, 24)
            
            // App tagline
            Text("Track smart. Spend wiser.")
                .font(.title2.italic())
                .foregroundStyle(.gray)
                .padding(.bottom, 80)
            
            Spacer()
            
            // Navigation button to next page
            Button(action: {
                withAnimation {
                    currentPage += 1
                }
            }) {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

// Reusable onboarding page displaying feature with icon, title, and description.
struct OnboardingPageView: View {
    // MARK: - Properties
    let iconName: String
    let title: String
    let description: String
    @Binding var currentPage: Int
    let totalPages: Int
    let isLastPage: Bool
    var onComplete: (() -> Void)? = nil
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Feature icon
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .padding(.top, 30)
            
            // Feature title
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
            
            // Feature description
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            
            Spacer()
            
            // Navigation button - "Next" or "Get Started" on final page
            Button(action: {
                if isLastPage {
                    onComplete?()
                } else {
                    withAnimation {
                        currentPage += 1
                    }
                }
            }) {
                Text(isLastPage ? "Get Started" : "Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
