import AppKit

final class AppMenuRowView: NSView {
    private let titleField = NSTextField(labelWithString: "")
    private let restartButton = NSButton()
    private let removeButton = NSButton()
    private var trackingAreaRef: NSTrackingArea?
    private var isHovered = false {
        didSet { updateHoverStyle() }
    }

    var onRestart: (() -> Void)?
    var onRemove: (() -> Void)?
    var actionsEnabled: Bool = true {
        didSet {
            restartButton.isEnabled = actionsEnabled
            removeButton.isEnabled = actionsEnabled
            if !actionsEnabled {
                titleField.textColor = NSColor.disabledControlTextColor
                restartButton.contentTintColor = NSColor.disabledControlTextColor
                removeButton.contentTintColor = NSColor.disabledControlTextColor
            } else {
                updateHoverStyle()
            }
        }
    }

    init(appName: String) {
        super.init(frame: NSRect(x: 0, y: 0, width: 1, height: 28))
        configureUI(appName: appName)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func configureUI(appName: String) {
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = 6
        layer?.masksToBounds = true
        titleField.stringValue = appName
        titleField.lineBreakMode = .byTruncatingTail
        titleField.translatesAutoresizingMaskIntoConstraints = false
        titleField.font = NSFont.menuFont(ofSize: 0)

        restartButton.bezelStyle = .texturedRounded
        restartButton.image = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: "Restart")
        restartButton.isBordered = false
        restartButton.target = self
        restartButton.action = #selector(handleRestart)
        restartButton.translatesAutoresizingMaskIntoConstraints = false

        removeButton.bezelStyle = .texturedRounded
        removeButton.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove")
        removeButton.isBordered = false
        removeButton.target = self
        removeButton.action = #selector(handleRemove)
        removeButton.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleField)
        addSubview(restartButton)
        addSubview(removeButton)

        NSLayoutConstraint.activate([
            widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            heightAnchor.constraint(equalToConstant: 28),

            // Custom NSMenuItem views start closer to the left edge than standard items.
            // Use a larger inset to visually align text baselines with native menu items.
            titleField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleField.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleField.trailingAnchor.constraint(lessThanOrEqualTo: restartButton.leadingAnchor, constant: -8),

            removeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            removeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: 16),
            removeButton.heightAnchor.constraint(equalToConstant: 16),

            restartButton.trailingAnchor.constraint(equalTo: removeButton.leadingAnchor, constant: -8),
            restartButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 16),
            restartButton.heightAnchor.constraint(equalToConstant: 16)
        ])
        updateHoverStyle()
    }

    override func updateTrackingAreas() {
        if let trackingAreaRef {
            removeTrackingArea(trackingAreaRef)
        }
        let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways, .inVisibleRect]
        let tracking = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(tracking)
        trackingAreaRef = tracking
        super.updateTrackingAreas()
    }

    override func mouseEntered(with event: NSEvent) {
        isHovered = true
    }

    override func mouseExited(with event: NSEvent) {
        isHovered = false
    }

    override func mouseDown(with event: NSEvent) {
        guard actionsEnabled else { return }
        onRestart?()
    }

    private func updateHoverStyle() {
        if !actionsEnabled {
            return
        }
        if isHovered {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.9).cgColor
            titleField.textColor = .white
            restartButton.contentTintColor = .white
            removeButton.contentTintColor = .white
        } else {
            layer?.backgroundColor = .clear
            titleField.textColor = NSColor.labelColor
            restartButton.contentTintColor = NSColor.tertiaryLabelColor
            removeButton.contentTintColor = NSColor.tertiaryLabelColor
        }
    }

    @objc
    private func handleRestart() {
        onRestart?()
    }

    @objc
    private func handleRemove() {
        onRemove?()
    }
}
