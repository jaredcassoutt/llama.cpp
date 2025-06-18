# Debugging Model Loading Crashes with llama.cpp XCFramework

## Common Crash: EXC_BAD_ACCESS in tokenizer

If you're getting `EXC_BAD_ACCESS (code=2, address=0x...)` when loading a model, this indicates a memory access violation in the tokenizer code.

## Step-by-Step Debugging

### 1. Verify Model File
```swift
import Foundation
import llama

func debugModelPath(_ modelPath: String) {
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
        print("✅ Model file exists, size: \(fileSize) bytes")
        
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
```

### 2. Safe Model Loading Pattern
```swift
import llama

func loadModelSafely(modelPath: String) -> OpaquePointer? {
    // Debug the file path first
    debugModelPath(modelPath)
    
    // Initialize backend if not already done
    llama_backend_init()
    
    // Create model parameters
    var model_params = llama_model_default_params()
    model_params.use_mmap = true  // Use memory mapping
    model_params.use_mlock = false  // Don't lock memory on mobile
    
    // Try to load the model
    print("🔄 Attempting to load model...")
    let model = llama_load_model_from_file(modelPath, model_params)
    
    if model == nil {
        print("❌ Failed to load model from: \(modelPath)")
        return nil
    }
    
    print("✅ Model loaded successfully")
    return model
}
```

### 3. Complete Safe Implementation
```swift
import Foundation
import llama

class LlamaModelManager {
    private var model: OpaquePointer?
    private var context: OpaquePointer?
    
    init() {
        llama_backend_init()
    }
    
    deinit {
        cleanup()
    }
    
    func loadModel(path: String) -> Bool {
        cleanup() // Clean up any existing model
        
        // Validate file path
        guard FileManager.default.fileExists(atPath: path) else {
            print("❌ Model file not found: \(path)")
            return false
        }
        
        // Load model with error checking
        var model_params = llama_model_default_params()
        model_params.use_mmap = true
        
        model = llama_load_model_from_file(path, model_params)
        guard model != nil else {
            print("❌ Failed to load model")
            return false
        }
        
        // Create context
        var ctx_params = llama_context_default_params()
        ctx_params.n_ctx = 2048
        ctx_params.n_threads = 4
        
        context = llama_new_context_with_model(model, ctx_params)
        guard context != nil else {
            print("❌ Failed to create context")
            llama_free_model(model)
            model = nil
            return false
        }
        
        print("✅ Model and context loaded successfully")
        return true
    }
    
    private func cleanup() {
        if let ctx = context {
            llama_free(ctx)
            context = nil
        }
        if let mdl = model {
            llama_free_model(mdl)
            model = nil
        }
    }
}
```

## Common Issues and Solutions

### Issue 1: Invalid Model Path
**Symptom**: Crash immediately when calling `llama_load_model_from_file`
**Solution**: Use absolute paths and verify file exists

```swift
// Wrong (relative path may not work)
let modelPath = "model.gguf"

// Right (absolute path)
let modelPath = Bundle.main.path(forResource: "model", ofType: "gguf") ?? ""
// Or for documents directory:
let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let modelPath = documentsPath.appendingPathComponent("model.gguf").path
```

### Issue 2: Corrupted or Incompatible Model
**Symptom**: Crash in tokenizer after model appears to load
**Solution**: 
- Verify model is valid GGUF format
- Try a different/smaller model first
- Check model compatibility with your llama.cpp version

### Issue 3: Memory Issues
**Symptom**: Crash with large models
**Solution**: 
```swift
var model_params = llama_model_default_params()
model_params.use_mmap = true  // Use memory mapping
model_params.use_mlock = false  // Don't lock memory on iOS/mobile
```

### Issue 4: Threading Issues
**Symptom**: Random crashes, especially on iOS
**Solution**: Always use llama.cpp from the same thread
```swift
class LlamaModelManager {
    private let queue = DispatchQueue(label: "llama.queue", qos: .userInitiated)
    
    func loadModel(path: String, completion: @escaping (Bool) -> Void) {
        queue.async {
            let success = self.loadModelSync(path: path)
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
```

## Debugging Steps

1. **Check model file**: Use `debugModelPath()` function above
2. **Try minimal loading**: Use the safe loading pattern
3. **Enable logging**: Set `LLAMA_LOG_LEVEL=DEBUG` environment variable
4. **Test with different model**: Try a smaller/different GGUF model
5. **Check memory**: Monitor memory usage in Xcode
6. **Verify threading**: Ensure all llama.cpp calls are on same thread

## Testing Your Fix

```swift
// Test script
let manager = LlamaModelManager()
let success = manager.loadModel(path: "/path/to/your/model.gguf")
if success {
    print("🎉 Model loaded successfully!")
} else {
    print("❌ Model loading failed")
}
```

## Getting Help

If the crash persists:
1. Share the exact model file you're using
2. Share your complete loading code
3. Include the full crash stack trace
4. Mention your platform (iOS/macOS) and device 