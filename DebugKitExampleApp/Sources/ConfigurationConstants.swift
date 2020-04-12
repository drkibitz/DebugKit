import DebugKit

public enum ConfigurationConstants {

    #if DEBUG
    public static let debugInfo: Debug.Info = {

        // No buildConfiguration defined for Release
        #if RELEASE
        let buildConfiguration = "ReleaseDebug"
        #else
        let buildConfiguration = "Debug"
        #endif

        // No compilationInfo defined for Release
        #if targetEnvironment(simulator)

        #if XCODE_ACTION_install
        let compilationInfo = "simulator install"
        #elseif XCODE_ACTION_build
        let compilationInfo = "simulator build"
        #else
        let compilationInfo = "simulator"
        #endif // XCODE_ACTION_$(ACTION)

        #else

        #if XCODE_ACTION_install
        let compilationInfo = "device install"
        #elseif XCODE_ACTION_build
        let compilationInfo = "device build"
        #else
        let compilationInfo = "device"
        #endif // XCODE_ACTION_$(ACTION)

        #endif // targetEnvironment

        return Debug.Info(
            buildConfiguration: buildConfiguration,
            compilationInfo: compilationInfo
        )
    }()
    #endif // DEBUG
}
