//
//  Filter.swift
//  Filter
//
//  Created by Andrew Sawyer on 9/17/21.
//  Learned from: https://avinashselvam.medium.com/hands-on-metal-image-processing-using-apples-gpu-framework-8e5306172765
//

import Foundation
import Metal
import MetalKit


struct FilterAttributes {
        var pixelSize: Int
}

class Filter {
    
    var device: MTLDevice = MTLCreateSystemDefaultDevice()!
    
    var defaultLib: MTLLibrary?
    var shader: MTLFunction?
    
    var commandQueue: MTLCommandQueue?
    var commandBuffer: MTLCommandBuffer?
    var commandEncoder: MTLComputeCommandEncoder?
    
    var pipelineState: MTLComputePipelineState?
    
    
    let threadsPerBlock = MTLSize(width: 16, height: 16, depth: 1) //TODO: understand this
    
    
    var inputImage: UIImage
    var width, height: Int
    
    
    
    init(image: UIImage) {
        inputImage = image
        
        defaultLib = device.makeDefaultLibrary()
        shader = defaultLib?.makeFunction(name: "shaderOne")
        commandQueue = device.makeCommandQueue()
        commandBuffer = commandQueue?.makeCommandBuffer()
        commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        if let shader = shader {
            pipelineState = try? device.makeComputePipelineState(function: shader)
        }
        
        width = Int(inputImage.size.width)
        height = Int(inputImage.size.height)
        
    }
    
    
    func applyFilter(with attributes: FilterAttributes) -> UIImage? {
        guard let encoder = self.commandEncoder,
              let buffer = self.commandBuffer,
              let pipelineState = pipelineState,
              
              let outputTexture = getEmptyMTLTexture(),
              let inputTexture = getInputMTLTexture()
        else {
            return nil
        }
        
        var params = attributes
        encoder.setBytes(&params, length: MemoryLayout<Filter>.size, index: 0)
        
        encoder.setTextures([outputTexture, inputTexture], range: 1..<3)
//        shaderMaterial.setValue(Data(bytes: &firstStrokeTimeVariableStruct, count: MemoryLayout<strokeTimeVariableStruct>.stride), forKey: "timeVariables");
        
        encoder.setComputePipelineState(pipelineState)
        encoder.dispatchThreadgroups(getBlockDimentions(), threadsPerThreadgroup: threadsPerBlock) //understand this
        encoder.endEncoding()
        
        
        buffer.commit()
        buffer.waitUntilCompleted()
        
        guard let cgOutput = getCGImage(from: outputTexture) else {
            return nil
        }
        
        return UIImage(cgImage: cgOutput)
        
    }
    
    
    private func getEmptyMTLTexture() -> MTLTexture? {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: width, height: height,
            mipmapped: false
        )
        
        descriptor.usage = [.shaderRead, .shaderWrite] //does it need to be both?
        
        return device.makeTexture(descriptor: descriptor)
    }
    
    private func getInputMTLTexture() -> MTLTexture? {
        guard let cgInput = getCGImage(from: inputImage) else { return nil }
        
        return getMTLTexture(from: cgInput)
    }
            
    private func getCGImage(from uiImage: UIImage) -> CGImage? {
        UIGraphicsBeginImageContext(uiImage.size)
        
        uiImage.draw(in: CGRect(origin: .zero, size: uiImage.size))
        let contextImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return contextImage?.cgImage
    }
    
    private func getMTLTexture(from cgImage: CGImage) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        
        do {
            let texture = try textureLoader.newTexture(cgImage: cgImage, options: nil)
            let textureDesciptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                mipmapped: false
            ) //why is textureDescriptor made here? it is never used.
            textureDesciptor.usage = [.shaderRead, .shaderWrite] //does it need to be both?
            return texture
            
        } catch {
            return nil
        }
    }
    
    private func getBlockDimentions() -> MTLSize {
        let blockWidth = width / threadsPerBlock.width
        let blockHeight = height / threadsPerBlock.height
        
        return MTLSizeMake(blockHeight, blockWidth, 1)
    }
    
    private func getCGImage(from outputTexture: MTLTexture) -> CGImage? {
        var data = Array<UInt8>(repeatElement(0, count: 4 * width * height)) //4 bytes per pixel
        
        outputTexture.getBytes(&data,
                               bytesPerRow: 4*width,
                               from: MTLRegionMake2D(0, 0, width, height),
                               mipmapLevel: 0)
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue) //what does this line mean?
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 4*width, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) //why 8 bitsPerComponent?
        
        return context?.makeImage()
    }
    
}
