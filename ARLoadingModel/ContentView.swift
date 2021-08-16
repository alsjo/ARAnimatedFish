//
//  ContentView.swift
//  ARLoadingModel
//
//  Created by vitalii on 08.08.2021.
//

import SwiftUI
import RealityKit
import Combine
struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

class MyEntity: Entity, HasAnchoring, HasModel, HasCollision {
	
}

var arView: ARView!
var model: MyEntity? = nil
let anchor = AnchorEntity()
private var cancellables = Set<AnyCancellable>()
var cancellable: AnyCancellable? = nil
struct ARViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> ARView {
		arView = ARView(frame: .zero)
		arView.debugOptions = .showPhysics

		cancellable = Entity.loadAsync(named: "RybaAnim.usdz")
			.sink(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					print("Unable to load a model due to error \(error)")
				}
				cancellable?.cancel()

			}, receiveValue: { (entity: Entity) in
				// Creating parent ModelEntity
				let parentEntity = ModelEntity()
				parentEntity.addChild(entity)
				cancellable?.cancel()
				print("Congrats! Model is successfully loaded!")
				anchor.addChild(parentEntity)
				anchor.position = [0, 0.1, 0]
				anchor.scale = [0.2, 0.2, 0.2]        // set appropriate scale
				arView.scene.anchors.append(anchor)

				// Playing availableAnimations on repeat
				entity.availableAnimations.forEach { entity.playAnimation($0.repeat()) }

				let entityBounds = entity.visualBounds(relativeTo: parentEntity)
				var center = entityBounds.center
				center.x += 0.3
				parentEntity.collision = CollisionComponent(shapes: [ShapeResource.generateBox(size: SIMD3<Float>(1.0, 0.3, 0.1)).offsetBy(translation: center)])
				arView.installGestures(.all, for: parentEntity)
			})

        return arView!
        
    }
	

    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
