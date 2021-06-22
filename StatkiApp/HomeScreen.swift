//
//  HomeScreen.swift
//  STATKI_SwiftUI
//
//  Created by Peter A. Jankowski on 6/6/21.
//

import SwiftUI

struct HomeScreen: View {
    
    @StateObject var appState = AppState.shared
    
    let shipblocklength: CGFloat = 45
    
    var body: some View {
        NavigationView {
            VStack{
                Image("Statki_Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350.0, height: 100.0)
                    .padding(10)
                    .offset(y: -30)
                
                Text("A game by Peter A. Jankowski.").font(.system(size: 12)).offset(y: -50)
                
                HStack(spacing: 0) {
                    Group {
                        EndBlock(rotation: Angle(degrees: 0)).aspectRatio(1, contentMode: .fit)
                        MiddleBlock().aspectRatio(1, contentMode: .fit)
                        MiddleBlock().aspectRatio(1, contentMode: .fit)
                        EndBlock(rotation: Angle(degrees: 180)).aspectRatio(1, contentMode: .fit)
                    }
                }
                .frame(width: shipblocklength * 4, height: shipblocklength)
                .offset(y: -55)
                
                NavigationLink(destination: GameView().environmentObject(ViewModel()).id(appState.gameID)) {
                    ButtonView(label: "New Game")
                }
                NavigationLink(destination: GameView().environmentObject(ViewModel()).id(appState.gameID)) {
                    ButtonView(label: "Continue")
                }
                NavigationLink(destination: GameView().environmentObject(ViewModel()).id(appState.gameID)) {
                    ButtonView(label: "About")
                }
            }
        }
    }
}

struct ButtonView: View {
    var label: String
    
    var body: some View {
        Text(label)
            .font(.system(size: 15))
            .foregroundColor(Color.white)
            .padding(5)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 100))
    
    }
}
