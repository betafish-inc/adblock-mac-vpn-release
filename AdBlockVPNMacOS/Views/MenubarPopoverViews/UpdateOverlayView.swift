//    AdBlock VPN
//    Copyright © 2020-present Adblock, Inc. All rights reserved.
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

import SwiftUI

struct UpdateOverlayView: View {
    var text: String
    var icon: String
    var background: Color
    var foreground: Color
    var body: some View {
        HStack {
            Spacer().frame(width: 16)
            Text(text)
                .latoFont()
            Spacer()
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24)
            Spacer().frame(width: 16)
        }
        .frame(width: 272, height: 40)
        .background(background)
        .foregroundColor(foreground)
        .mask(RoundedBottom(radius: 6))
    }
}

struct RoundedBottom: Shape {
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let topLeft = CGPoint(x: rect.minX, y: rect.minY)
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRightStart = CGPoint(x: rect.maxX, y: rect.maxY - radius)
        let bottomRightCenter = CGPoint(x: rect.maxX - radius, y: rect.maxY - radius)
        let bottomLeftStart = CGPoint(x: rect.minX + radius, y: rect.maxY)
        let bottomLeftCenter = CGPoint(x: rect.minX + radius, y: rect.maxY - radius)
        
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRightStart)
        path.addRelativeArc(center: bottomRightCenter, radius: radius,
          startAngle: Angle.degrees(0), delta: Angle.degrees(90))
        path.addLine(to: bottomLeftStart)
        path.addRelativeArc(center: bottomLeftCenter, radius: radius,
          startAngle: Angle.degrees(90), delta: Angle.degrees(90))
        
        return path
    }
}

struct UpdateOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UpdateOverlayView(text: "Update Complete!", icon: "CheckIcon", background: .abUpToDateAccent, foreground: .white)
            UpdateOverlayView(text: "Update required in XX days", icon: "TimerIcon", background: .abUpdateAccent, foreground: .abDarkText)
        }
    }
}
