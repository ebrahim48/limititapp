import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Draws the screen iOS shows when a blocked app is opened.
///
/// Apple fixes the layout (icon, title, subtitle, buttons); we only swap the
/// system hourglass for our app icon and keep the stock wording.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        configuration(for: application.localizedDisplayName)
    }

    override func configuration(
        shielding application: Application,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        configuration(for: application.localizedDisplayName)
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        configuration(for: webDomain.domain)
    }

    override func configuration(
        shielding webDomain: WebDomain,
        in category: ActivityCategory
    ) -> ShieldConfiguration {
        configuration(for: webDomain.domain)
    }

    private func configuration(for name: String?) -> ShieldConfiguration {
        ShieldConfiguration(
            icon: UIImage(named: "ShieldIcon"),
            title: ShieldConfiguration.Label(text: "Restricted", color: .label),
            subtitle: ShieldConfiguration.Label(
                text: "You cannot use \(name ?? "this app") because it is restricted.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(text: "OK", color: .white),
            primaryButtonBackgroundColor: .systemBlue
        )
    }
}
