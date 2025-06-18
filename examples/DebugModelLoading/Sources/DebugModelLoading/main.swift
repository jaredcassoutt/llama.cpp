import Foundation
import llama

// Debug Model Loading Issues
print("🔍 llama.cpp Model Loading Debugger")
print("==================================")

func debugModelPath(_ modelPath: String) {
    print("\n📁 Checking model file...")
    let fileManager = FileManager.default
    
    // Check if file exists
    guard fileManager.fileExists(atPath: modelPath) else {
        print("❌ Model file does not exist at: \(modelPath)")
        return
    }
    
    // Check file size
    do {
        let attributes = try fileManager.attributesOfItem(atPath: modelPath)
        let fileSize = attributes[.size] as? Int64 ?? 0
        print("✅ Model file exists, size: \(fileSize) bytes (\(fileSize / 1024 / 1024) MB)")
        
        if fileSize < 1024 * 1024 {  // Less than 1MB
            print("⚠️  Warning: Model file seems very small")
        }
    } catch {
        print("❌ Could not read file attributes: \(error)")
    }
    
    // Check file extension
    if !modelPath.hasSuffix(".gguf") {
        print("⚠️  Warning: Model file should have .gguf extension")
    }
}

func testBasicAPI() {
    print("\n🧪 Testing basic API...")
    
    // Initialize backend
    llama_backend_init()
    print("✅ Backend initialized")
    
    // Test parameter creation
    let _ = llama_model_default_params()
    print("✅ Model params created")
    
    let _ = llama_context_default_params()
    print("✅ Context params created")
    
    llama_backend_free()
    print("✅ Backend cleaned up")
}

func loadModelSafely(modelPath: String) -> Bool {
    print("\n🔄 Attempting safe model loading...")
    
    // Debug the file path first
    debugModelPath(modelPath)
    
    // Initialize backend
    llama_backend_init()
    
    // Create model parameters with safe defaults
    var model_params = llama_model_default_params()
    model_params.use_mmap = true      // Use memory mapping
    model_params.use_mlock = false    // Don't lock memory on mobile
    model_params.n_gpu_layers = 0     // Use CPU only for debugging
    
    print("📋 Model parameters:")
    print("   use_mmap: \(model_params.use_mmap)")
    print("   use_mlock: \(model_params.use_mlock)")
    print("   n_gpu_layers: \(model_params.n_gpu_layers)")
    
    // Try to load the model
    print("🔄 Loading model...")
    let model = llama_model_load_from_file(modelPath, model_params)
    
    if model == nil {
        print("❌ Failed to load model from: \(modelPath)")
        llama_backend_free()
        return false
    }
    
    print("✅ Model loaded successfully!")
    
    // Try to create context
    var ctx_params = llama_context_default_params()
    ctx_params.n_ctx = 512  // Small context for testing
    ctx_params.n_threads = 1  // Single thread for debugging
    
    print("🔄 Creating context...")
    let context = llama_init_from_model(model, ctx_params)
    
    if context == nil {
        print("❌ Failed to create context")
        llama_model_free(model)
        llama_backend_free()
        return false
    }
    
    print("✅ Context created successfully!")
    
    // Test tokenization (this is where your crash happens)
    print("🔄 Testing tokenization...")
    let testText = "Hello"
    let maxTokens = 10
    var tokens = Array<Int32>(repeating: 0, count: maxTokens)
    
    let tokenCount = llama_tokenize(model, testText, Int32(testText.count), &tokens, Int32(maxTokens), true, false)
    
    if tokenCount > 0 {
        print("✅ Tokenization successful! Generated \(tokenCount) tokens")
        print("   Tokens: \(Array(tokens[0..<Int(tokenCount)]))")
    } else {
        print("❌ Tokenization failed")
    }
    
    // Clean up
    llama_free(context)
    llama_model_free(model)
    llama_backend_free()
    
    return true
}

// Main debugging sequence
print("1️⃣ Testing basic API...")
testBasicAPI()

print("\n2️⃣ Ready to test model loading")
print("Usage: provide model path as command line argument")
print("Example: swift run DebugModelLoading /path/to/your/model.gguf")

// Check command line arguments
let arguments = CommandLine.arguments
if arguments.count > 1 {
    let modelPath = arguments[1]
    print("\n3️⃣ Testing model: \(modelPath)")
    
    let success = loadModelSafely(modelPath: modelPath)
    
    if success {
        print("\n🎉 Model loading test completed successfully!")
    } else {
        print("\n❌ Model loading test failed")
        print("\nTroubleshooting tips:")
        print("• Verify the model file is a valid GGUF format")
        print("• Try a smaller model first")
        print("• Check available memory")
        print("• Ensure you have read permissions")
    }
} else {
    print("\n💡 To test model loading, run:")
    print("swift run DebugModelLoading /path/to/your/model.gguf")
}

print("\n📖 For more help, see: DEBUG_MODEL_LOADING.md") 