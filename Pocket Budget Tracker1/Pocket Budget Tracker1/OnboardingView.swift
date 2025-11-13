//
//  OnboardingView.swift
//  Pocket Budget Tracker1
//
//  Created by IM Student on 2025-11-11.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Welcome Screen with Logo and Tagline
                WelcomePageView(
                    currentPage: $currentPage
                )
                .tag(0)
                
                OnboardingPageView(
                    iconName: "creditcard",
                    title: "Track Every Expense",
                    description: "Record your income and expenses effortlessly.",
                    currentPage: $currentPage,
                    totalPages: 4,
                    isLastPage: false
                )
                .tag(1)
                
                OnboardingPageView(
                    iconName: "chart.bar.xaxis",
                    title: "Visualize Your Spending",
                    description: "View insightful charts and spending patterns.",
                    currentPage: $currentPage,
                    totalPages: 4,
                    isLastPage: false
                )
                .tag(2)
                
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

// Welcome Screen (First Screen)
struct WelcomePageView: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo
            Image("AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .padding(.bottom, 24)
            
            // Tagline
            Text("Track smart. Spend wiser.")
                .font(.title2.italic())
                .foregroundStyle(.gray)
                .padding(.bottom, 80)
            
            Spacer()
            
            // Next Button
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

struct OnboardingPageView: View {
    let iconName: String
    let title: String
    let description: String
    @Binding var currentPage: Int
    let totalPages: Int
    let isLastPage: Bool
    var onComplete: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Icon
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundStyle(.blue)
                .padding(.top, 30)
            
            // Title
            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 16)
            
            // Description
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            
            Spacer()
            
            // Button
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
