import SwiftUI
import SwiftUISugar
import FoodLabel
import PrepDataTypes

extension FoodForm {
    var detailsSection: some View {
        FormStyledSection(header: Text("Details")) {
            NavigationLink {
                DetailsForm(name: $name, detail: $detail, brand: $brand)
            } label: {
                if detailsAreEmpty {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                } else {
                    FoodDetailsView(emoji: $emoji, name: $name, detail: $detail, brand: $brand, didTapEmoji: {
                        showingEmojiPicker = true
                    })
                }
            }
        }
    }
    
    var sourcesSection: some View {
        SourcesView(sources: sources,
                    didTapAddSource: tappedAddSource,
                    handleSourcesAction: handleSourcesAction)
    }
    
    var foodLabelSection: some View {
        @ViewBuilder var header: some View {
            if !fields.shouldShowFoodLabel {
                Text("Nutrition Facts")
            }
        }
        
        return FormStyledSection(header: header) {
            NavigationLink {
                NutrientsList()
                    .environmentObject(fields)
                    .environmentObject(sources)
            } label: {
                if fields.shouldShowFoodLabel {
                    foodLabel
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    var prefillSection: some View {
        if let url = fields.prefilledFood?.sourceUrl {
            FormStyledSection(header: Text("Prefilled Food")) {
                NavigationLink {
                    WebView(urlString: url)
                } label: {
                    LinkCell(LinkInfo("https://myfitnesspal.com")!, title: "MyFitnessPal")
                }
            }
        }
    }
    
    var servingSection: some View {
        FormStyledSection(header: Text("Amount Per")) {
            NavigationLink {
                Color.blue
//                AmountPerForm()
            } label: {
                if fields.hasAmount {
                    foodAmountView
                } else {
                    Text("Required")
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
    }
    
    var barcodesSection: some View {
        var header: some View {
            Text("Barcodes")
        }
        
        var footer: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text("This will allow you to scan and quickly find this food again later.")
                    .foregroundColor(Color(.secondaryLabel))
                    .multilineTextAlignment(.leading)
            }
            .font(.footnote)
        }
        
        return Group {
            if !fields.barcodes.isEmpty {
                FormStyledSection(
                    header: header,
                    footer: footer,
                    horizontalPadding: 0,
                    verticalPadding: 0)
                {
                    NavigationLink {
    //                    BarcodesForm()
    //                        .environmentObject(viewModel)
                    } label: {
                        BarcodesView(
                            barcodeValues: Binding<[FieldValue]>(
                                get: { fields.barcodes.map { $0.value } },
                                set: { _ in }
                            ),
                            showAsSquares: Binding<Bool>(
                                get: { fields.hasSquareBarcodes },
                                set: { _ in }
                            )
                        )
                    }
                }
            } else {
                FormStyledSection(header: header, footer: footer) {
                    Button {
//                        viewModel.showingAddBarcodeMenu = true
                    } label: {
                        Text("Add a barcode")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
    }
}
