//
//  ViewController.swift
//  DrawingApp
//
//  Created by 박진섭 on 2022/02/28.
//

import UIKit
import OSLog

class MainViewController: UIViewController{

    //model
    var plane = Plane()
    //view
    var detailView = DetailView()
    var rectangleView = RectangleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailView.delegate = self
        
        configureTapGesture()
        configureDeatailView()
        configureRectangleButton()
        
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    private func configureDeatailView() {
        detailView.frame = CGRect(
            x: self.view.frame.maxX - 200,
            y: 0,
            width: 200,
            height: self.view.frame.height
        )
        self.view.addSubview(detailView)
    }
    
    
    //버튼 정의
    private func configureRectangleButton() {
        // 820 X 1180
        let width = 150.0
        let height = 100.0
        let x = (Point.maxX / 2) - (width / 2)
        let y = (Point.maxY - height) - 30
        
        let squareImage = UIImage(systemName: "square")
        let highlightedImage = UIImage(systemName: "square.fill")
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = "사각형"
        
        configuration.image = squareImage
        
        configuration.imagePlacement = .top
        configuration.imagePadding = 20
        
        configuration.background.backgroundColor = .secondarySystemBackground
        configuration.background.cornerRadius = 10
        
        let button = UIButton(configuration: configuration, primaryAction: makeRectangleAction())
        
        button.tintColor = .black
        button.frame = CGRect(x: x, y: y, width: width, height: height)
        
        //사각형 버튼 터치시 변화를 보여주기 위해 선언함.
        button.configurationUpdateHandler = { button in
            var configuration = button.configuration
            configuration?.image = button.isHighlighted ? highlightedImage : squareImage
            button.configuration = configuration
        }
        
        view.addSubview(button)
    }
    
    //버튼 액션정의
    private func makeRectangleAction() -> UIAction {
        let action = UIAction {_ in
            let id = IDFactory.makeRandomID()
            let size = Size(width: 150, height: 120)
            let point = PointFactory.makeRandomPoint()
            let rgb = RGBFactory.makeRandomRGB()
            let alpha = AlphaFactory.makeRandomAlpha()
            
            let rect = Rectangle(id: id, origin: point, size: size, backGroundColor: rgb, alpha: alpha)
            let rectView = UIView(rect: rect, rgb: rgb, alpha: alpha)
            
            self.plane.rectangles.append(rect)                                  //모델에 rectangle을 추가
            self.rectangleView.views.append(rectView)                           //view에 retangleView를 추가
            
            self.view.addSubview(rectView)
        }
        return action
    }
    

}

//MARK: -- UIGesture 처리
extension MainViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        let touchedView = self.view.hitTest(touch.location(in: self.view), with: nil)
        
        //터치한 곳의 View의 크기를 비교해서 직사각형의 유무를 파악합니다.
        if touchedView?.frame.size == CGSize(width: 150, height: 120) {
            //기존에 seletedRectanlge이 있다면 테두리를 원상복구 시키고 새롭게 선택된 rectangle의 테두리를 검게 칠합니다.
            self.rectangleView.selectedView.layer.borderWidth = 0.0
            
            touchedView?.layer.borderWidth = 2.0
            touchedView?.layer.borderColor = UIColor.black.cgColor
            self.rectangleView.selectedView = touchedView ?? UIView()
            
            //detailView를 클릭했을시에도 테두리가 사라지지 않게 하기위해 빈화면크기의 View를 클릭했을 시에만 테두리를 없앱니다.
        } else if touchedView?.frame.size == CGSize(width: 1180, height: 820){
            self.rectangleView.selectedView.layer.borderWidth = 0.0
        }
        
        return true
    }
}

//MARK: -- Delegate메소드 실제 구현

//슬라이더를 움직일때 마다 현재 클릭한 사각형의 alpha값을 바꾼다.
extension MainViewController:DetailViewDelgate {
    func changeAlpha(sender: UISlider) {
        let currentSliderValue = sender.value
        self.rectangleView.selectedView.alpha = CGFloat(currentSliderValue)
        self.detailView.alphaLabel.text = "투명도 \(currentSliderValue)"
    }
    
    func changeColor() {
        print("Change Color Label!")
    }
}