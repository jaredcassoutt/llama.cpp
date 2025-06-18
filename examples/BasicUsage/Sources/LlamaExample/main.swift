import Foundation
import llama

// Basic llama.cpp XCFramework usage example

print("🦙 llama.cpp XCFramework Example")
print("================================")

// Example: Check if we can access basic llama.cpp functions
// Note: This is a minimal example showing framework integration
// For a complete llama.cpp application, you would need to load a model file

func checkFrameworkIntegration() {
    // Print the llama.cpp build info to verify the framework is loaded
    // This calls the actual llama.cpp C API through the XCFramework
    let buildInfo = String(cString: llama_print_system_info())
    print("Build Info:")
    print(buildInfo)
}

func demonstrateBasicAPI() {
    print("\n📚 Basic API Demonstration:")
    
    // Initialize llama backend
    llama_backend_init()
    print("✅ Backend initialized")
    
    // Example: Create model params with default values
    var model_params = llama_model_default_params()
    model_params.n_gpu_layers = 0  // Use CPU only for this example
    print("✅ Model params created")
    
    // Example: Create context params with default values  
    var ctx_params = llama_context_default_params()
    ctx_params.n_ctx = 512  // Context size
    print("✅ Context params created")
    
    print("\n💡 Framework integration successful!")
    print("   The llama.cpp XCFramework is properly loaded and accessible.")
    print("   To use with a real model, provide a .gguf model file path to llama_load_model_from_file()")
    
    // Clean up
    llama_backend_free()
    print("✅ Backend cleaned up")
}

// Run the examples
checkFrameworkIntegration()
demonstrateBasicAPI()

print("\n🎉 Example completed successfully!")
print("📖 For more information, see: https://github.com/ggml-org/llama.cpp") 