Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Splash Screen ---
$splash = New-Object System.Windows.Forms.Form
$splash.Text = "Loading Note Edit..."
$splash.Size = New-Object System.Drawing.Size(400,200)
$splash.StartPosition = "CenterScreen"
$splash.BackColor = [System.Drawing.Color]::LightBlue

$label = New-Object System.Windows.Forms.Label
$label.Text = "Starting Note Edit..."
$label.Font = New-Object System.Drawing.Font("Segoe UI",14,[System.Drawing.FontStyle]::Bold)
$label.AutoSize = $true
$label.Location = New-Object System.Drawing.Point(100,80)
$splash.Controls.Add($label)

$splash.Show()
Start-Sleep -Seconds 2
$splash.Close()

# --- Main Editor ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Note Edit"
$form.Size = New-Object System.Drawing.Size(1100,750)
$form.BackColor = [System.Drawing.Color]::WhiteSmoke

# RichTextBox
$textBox = New-Object System.Windows.Forms.RichTextBox
$textBox.Multiline = $true
$textBox.Dock = "Fill"
$textBox.ScrollBars = "Both"
$textBox.Font = New-Object System.Drawing.Font("Segoe UI",12)
$form.Controls.Add($textBox)

# Menu bar
$menu = New-Object System.Windows.Forms.MenuStrip

# File menu
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")

# Open
$openItem = New-Object System.Windows.Forms.ToolStripMenuItem("Open")
$openItem.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "Text (*.txt)|*.txt|Rich Text (*.rtf)|*.rtf"
    if ($dialog.ShowDialog() -eq "OK") {
        if ($dialog.FileName.EndsWith(".rtf")) {
            $textBox.LoadFile($dialog.FileName, [System.Windows.Forms.RichTextBoxStreamType]::RichText)
        } else {
            $textBox.Text = [System.IO.File]::ReadAllText($dialog.FileName)
        }
    }
})

# Save
$saveItem = New-Object System.Windows.Forms.ToolStripMenuItem("Save")
$saveItem.Add_Click({
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    $dialog.Filter = "Text (*.txt)|*.txt|Rich Text (*.rtf)|*.rtf|PDF (*.pdf)|*.pdf"
    if ($dialog.ShowDialog() -eq "OK") {
        try {
            if ($dialog.FileName.EndsWith(".rtf")) {
                $textBox.SaveFile($dialog.FileName, [System.Windows.Forms.RichTextBoxStreamType]::RichText)
            } elseif ($dialog.FileName.EndsWith(".txt")) {
                [System.IO.File]::WriteAllText($dialog.FileName, $textBox.Text)
            } elseif ($dialog.FileName.EndsWith(".pdf")) {
                $printDoc = New-Object System.Drawing.Printing.PrintDocument
                $printDoc.add_PrintPage({
                    param($s,$eArgs)
                    $eArgs.Graphics.DrawString($textBox.Text, $textBox.Font, [System.Drawing.Brushes]::Black, $eArgs.MarginBounds)
                })
                $pd = New-Object System.Windows.Forms.PrintDialog
                $pd.Document = $printDoc
                $pd.UseEXDialog = $true
                if ($pd.ShowDialog() -eq "OK") {
                    $printDoc.PrinterSettings = $pd.PrinterSettings
                    $printDoc.Print()
                } else {
                    throw "PDF save cancelled or printer not available."
                }
            }
            [System.Windows.Forms.MessageBox]::Show("File saved successfully!","Save", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Error saving file: $_","Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})

# Exit
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
$exitItem.Add_Click({ $form.Close() })

# About
$aboutItem = New-Object System.Windows.Forms.ToolStripMenuItem("About")
$aboutItem.Add_Click({
    [System.Windows.Forms.MessageBox]::Show(
        "Note Edit v1.0`nCreated by Tech ARV Studios",
        "About Note Edit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
})

$fileMenu.DropDownItems.AddRange(@($openItem,$saveItem,$exitItem,$aboutItem))
$menu.Items.Add($fileMenu)

# --- Toolbar (Ribbon) ---
$toolBar = New-Object System.Windows.Forms.ToolStrip
$toolBar.Dock = "Top"

# Bold button
$btnBold = New-Object System.Windows.Forms.ToolStripButton("Bold")
$btnBold.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$btnBold.ForeColor = [System.Drawing.Color]::DarkBlue
$btnBold.Add_Click({
    if ($textBox.SelectionFont) {
        $currentFont = $textBox.SelectionFont
        $newStyle = $currentFont.Style -bxor [System.Drawing.FontStyle]::Bold
        $textBox.SelectionFont = New-Object System.Drawing.Font($currentFont, $newStyle)
    }
})

# Italic button
$btnItalic = New-Object System.Windows.Forms.ToolStripButton("Italic")
$btnItalic.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Italic)
$btnItalic.ForeColor = [System.Drawing.Color]::DarkGreen
$btnItalic.Add_Click({
    if ($textBox.SelectionFont) {
        $currentFont = $textBox.SelectionFont
        $newStyle = $currentFont.Style -bxor [System.Drawing.FontStyle]::Italic
        $textBox.SelectionFont = New-Object System.Drawing.Font($currentFont, $newStyle)
    }
})

# Underline button
$btnUnderline = New-Object System.Windows.Forms.ToolStripButton("Underline")
$btnUnderline.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Underline)
$btnUnderline.ForeColor = [System.Drawing.Color]::DarkRed
$btnUnderline.Add_Click({
    if ($textBox.SelectionFont) {
        $currentFont = $textBox.SelectionFont
        $newStyle = $currentFont.Style -bxor [System.Drawing.FontStyle]::Underline
        $textBox.SelectionFont = New-Object System.Drawing.Font($currentFont, $newStyle)
    }
})

# Color button
$btnColor = New-Object System.Windows.Forms.ToolStripButton("Text Color")
$btnColor.ForeColor = [System.Drawing.Color]::Purple
$btnColor.Add_Click({
    $dialog = New-Object System.Windows.Forms.ColorDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $textBox.SelectionColor = $dialog.Color
    }
})

# Zoom buttons
$btnZoomIn = New-Object System.Windows.Forms.ToolStripButton("Zoom +")
$btnZoomOut = New-Object System.Windows.Forms.ToolStripButton("Zoom -")
$btnZoomIn.Add_Click({ $textBox.ZoomFactor += 0.1 })
$btnZoomOut.Add_Click({ if ($textBox.ZoomFactor -gt 0.2) { $textBox.ZoomFactor -= 0.1 } })

# Font dropdown
$fontDrop = New-Object System.Windows.Forms.ToolStripComboBox
$fontDrop.Items.AddRange([System.Drawing.FontFamily]::Families.Name)
$fontDrop.Text = "Segoe UI"
$fontDrop.AutoSize = $true
$fontDrop.Add_SelectedIndexChanged({
    if ($textBox.SelectionFont) {
        $currentFont = $textBox.SelectionFont
        $textBox.SelectionFont = New-Object System.Drawing.Font($fontDrop.Text, $currentFont.Size, $currentFont.Style)
    } else {
        $textBox.Font = New-Object System.Drawing.Font($fontDrop.Text, $textBox.Font.Size)
    }
})

$toolBar.Items.AddRange(@($btnBold,$btnItalic,$btnUnderline,$btnColor,$btnZoomIn,$btnZoomOut,$fontDrop))

$form.Controls.Add($toolBar)

$form.MainMenuStrip = $menu
$form.Controls.Add($menu)

# Show form
$form.ShowDialog()
