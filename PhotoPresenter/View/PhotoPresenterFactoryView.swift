//
//  PresenterFactoryView.swift
//  PhotoPresenter
//
//  Created by Alain Lafontaine on 2026-01-16.
//


/*
 
 
 "photoPresenterHeader" : {
    "description" : "3 photos de Christiane en lingegerie",
    "name" : "Christiane",
    "orientation" : "Horizontal",
    "ratio" : 1.4249740639441668
  }
 
 
*/


import AppKit
import SwiftUI
import SwiftUtilities

struct PhotoPresenterFactoryView: View {

    @State private var directoriesInfo: [DirectoryInfo]
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var ratioList: String = "0.55;0.65;0.75;0.85;0.95;1.05;1.15;1.25;1.35;1.45;1.55;1.65;1.75;1.85"
    @State private var ratios: [Double] = [0.55, 0.65, 0.75, 0.85, 0.95, 1.05, 1.15, 1.25, 1.35, 1.45, 1.55, 1.65, 1.75, 1.85]
    @State private var tolerance: Double = 0.05
    @State private var analysisResultats: [AnalysisResultat] = []
    
    var body: some View {
        VStack() {
            Text("Photo presenter factory view").padding(.bottom, 4)
            
            HStack() {
                GroupBox("Paramètres pour la création du presenter") {
                    VStack(alignment: .leading, spacing: 8) {
                        // Nom des presenter
                        HStack() {
                            Text("Nom: ").padding(.bottom, 4)
                            TextField("Entre le nom du presenter", text: $name).frame(width: 200)
                        }

                        // Description
                        HStack() {
                            Text("Description: ").padding(.bottom, 4)
                            TextField("Entre la description", text: $description).frame(width: 170)
                        }

                        // Orientation
                        HStack() {
                            Text("Orientation: ").padding(.bottom, 4)
                            Text("Horizontal")
                        }.padding(.bottom, 8)
                        
                        HStack() {
                            Text("Ratio(s): ").padding(.bottom, 4)
                            TextField("Entre le ratio", text: $ratioList)
                        }.padding(.bottom, 8)

                        HStack() {
                            Text("Tolérance: ").padding(.bottom, 4)
                            TextField("Entre la tolérance", value: $tolerance, format: .number)
                        }.padding(.bottom, 8)

                        HStack() {
                            Spacer()
                            Button("Lancer l'analyse") {
                                ProcessAnalysisPhoto()
                            }.disabled(directoriesInfo.isEmpty)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                }
                .frame(width: 400,)
                .padding(.top, 8)
                
                GroupBox("Résultat de l'analyse") {
                    VStack(alignment: .leading, spacing: 8) {

                        if !directoriesInfo.isEmpty {
                            if analysisResultats.isEmpty {
                                Text("\(getNbOfPhotos()) photo(s) à analysée(s)")
                            } else {
                                Text("\(getNbOfPhotos()) photo(s) analysée(s)")
                                HStack() {
                                    Text("\(getNbOfPhotoInResultat()) photo(s)")
                                    Spacer()
                                    Text("Converture: \(getPourcentage(quotient: getNbOfPhotoInResultat(), diviseur: getNbOfPhotos()) * 100.0, specifier: "%.1f") %")
                                }.padding(.bottom, 16)
                                
                                HStack() {
                                    VStack(alignment: .leading, spacing: 4) {
                                        // --- En-tête ---
                                        HStack {
                                            Text("✓")
                                                .frame(width: 40, alignment: .center)
                                            Text("Ratio")
                                                .frame(width: 50, alignment: .center)

                                            Text("Photos")
                                                .frame(width: 80, alignment: .center)

                                            Text("Suffixe")
                                                .frame(width: 80, alignment: .center)
                                        }
                                        .font(.headline)
                                        .padding(.bottom, 4)
                                        
                                        List {
                                            ForEach($analysisResultats) { $item in
                                                HStack {

                                                    // Colonne 1 : Checkbox
                                                    Toggle("", isOn: $item.isChecked)
                                                        .labelsHidden()
                                                        .frame(width: 40, alignment: .leading)

                                                    // Colonne 2 : Ratio
                                                    Text(String(format: "%.3f", item.ratio))
                                                        .frame(width: 50, alignment: .leading)

                                                    // Colonne 3 : Nombre d’items
                                                    Text("\(item.NbOfFiles())")
                                                        .frame(width: 80, alignment: .trailing)

                                                    // Colonne 4 : Suffixe éditable
                                                    TextField("Suffix", text: $item.suffix)
                                                        .textFieldStyle(.roundedBorder)
                                                        .frame(width: 80, alignment: .leading)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                    }.frame(width: 300)
                                    
                                    VStack() {
                                        Text("Position pour image")
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        HStack() {
                            Spacer()
                            Button("Création du presenter") {
                                CreatePresenter()
                            }
                            .disabled(analysisResultats.isEmpty)
                        }
                        
                    }.padding(8)
                }
            }
            
            GroupBox("Source de données") {
                HStack() {
                    VStack(alignment: .leading) {
                        // --- En-tête ---
                        HStack {
                            Text("✓")
                                .frame(width: 40, alignment: .leading)

                            Text("Répertoire")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("# files")
                                .frame(width: 40, alignment: .leading)
                        }
                        .font(.headline)
                        .padding(.bottom, 4)

                        // --- Lignes ---
                        List {
                            ForEach($directoriesInfo) { $directoryInfo in
                                HStack {
                                    Toggle("", isOn: $directoryInfo.isChecked)
                                        .labelsHidden()
                                        .frame(width: 40, alignment: .leading)
                                        .onChange(of: directoryInfo.isChecked) { oldValue, newValue in
                                            analysisResultats.removeAll()
                                            }
                                        
                                    Text(directoryInfo.path)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(formatNombre(directoryInfo.fileInfos.count))
                                        .frame(width: 40, alignment: .trailing)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        
                        HStack() {
                            Spacer()
                            Button("Ajouter") {
                                addDirectory()
                            }
                        }
                    }.padding()
                }
            }.padding(.top, 16)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    init(dirInfos: [DirectoryInfo] = []) {
        self.directoriesInfo = dirInfos
    }
    
    private func addDirectory() {
        let url = selectDirectory()
        
        if let url {
            // Vérifie si nous avons un fichier index dans le répertoire
            let filename = "\(url.path)/PresenterIndex.json"
            
            var presenterIndex = openPresenterIndexFile(fullpath: filename)
            
            if presenterIndex == nil {
                let fileInfos: [FileDirectoryInfo] = retrieveFile(directory: url.path)
                let fileHeader = FileHeader(version: "0.1.0001", fileType: FileType.PresenterFileIndex)
                
                presenterIndex = PresenterFileIndex(
                    fileHeader: fileHeader,
                    fileInfos: fileInfos
                )
                
                // Sauvegarde le fichier pour le futur
                saveToJSONFile(presenterIndex, filename: filename)
            }
            
            directoriesInfo.append(DirectoryInfo(isChecked: true, path: url.path, fileInfos: presenterIndex!.fileInfos))
            analysisResultats.removeAll()
        }
    }
    
    private func CreatePresenter() {
        analysisResultats.forEach { analysisResultat in
            if analysisResultat.isChecked {
                let fileHeader =  FileHeader(version: "0.1.0003", fileType: FileType.PhotoPresenter)
                let photoPresenterHeader = PhotoPresenterHeader(
                                                name: "\(self.name) volume \(analysisResultat.suffix)",
                                                description: self.description,
                                                orientation: Orientation.Horizontal,
                                           )
                var groupedViews: [GroupedView] = []
                var photoPresenterDataSources: [PhotoPresenterDataSource] = []
                var directorySelected: [String] = []
                var fastLoadings: [FastLoading] = []
                let fastLoading: FastLoading = FastLoading()
                
                fastLoadings.append(fastLoading)
                
                directoriesInfo.forEach { directoryInfo in
                    if directoryInfo.isChecked {
                        directorySelected.append(directoryInfo.path)
                        fastLoading.directories.append(directoryInfo.path)
                    }
                }
                
                photoPresenterDataSources.append(
                    PhotoPresenterDataSource(
                        type: .DirectorySelected,
                        directorySelected: directorySelected,
                        ratio: analysisResultat.ratio,
                        tolerance: self.tolerance
                    )
                )
                
                var ratio: Double = 0
                analysisResultat.resultats.forEach { linkDirToFileDirectoryInfo in
                    let directoryIndex = linkDirToFileDirectoryInfo.directoryIndex
                    
                    linkDirToFileDirectoryInfo.fileInfos.forEach { fileDirectoryInfo in
                        fastLoading.fileInfos.append(
                                                FileInfo(
                                                    filename: fileDirectoryInfo.filename,
                                                    directoryIndex: directoryIndex,
                                                    width: fileDirectoryInfo.width,
                                                    height: fileDirectoryInfo.height
                                                )
                                            )
                        ratio += fileDirectoryInfo.ratio
                    }
                }
                photoPresenterHeader.ratio = ratio / Double(analysisResultat.resultats.count)
                
                groupedViews.append(
                    GroupedView(
                        nbOfView: 1,
                        photoPresenterDataSources: photoPresenterDataSources,
                        fastLoaddings: fastLoadings
                    )
                )
                
                let photoPresenter = PhotoPresenter(
                    fileHeader: fileHeader,
                    photoPresenterHeader: photoPresenterHeader,
                    groupedViews: groupedViews
                )
                
                saveToJSONFile(photoPresenter, filename: "/Volumes/Image_Mac/Config/\(self.name)_\(analysisResultat.suffix).json")
            }
        }
    }
    
    private func ProcessAnalysisPhoto() {
        var count: Int = 1
        analysisResultats.removeAll()
        
        ratios.forEach { ratio in
            let borneMin: Double = ratio - tolerance
            let borneMax: Double = ratio + tolerance
            var resultForRatio: [LinkDirectoryToFileDirectoryInfo] = []
            var directoryIndex: Int = 0
            
            directoriesInfo.forEach { directoryInfo in
                if directoryInfo.isChecked {
                    let fileInfos = directoryInfo.fileInfos
                    var link = LinkDirectoryToFileDirectoryInfo(
                        directoryIndex: directoryIndex,
                        fileInfos: []
                    )
                                        
                    for fileInfo in fileInfos {
                        if borneMin < fileInfo.ratio && borneMax >= fileInfo.ratio {
                            link.fileInfos.append(fileInfo)
                        }
                    }
                    
                    resultForRatio.append(link)
                    directoryIndex += 1
                }
            }
            
            analysisResultats.append(AnalysisResultat(
                isChecked: true,
                ratio: ratio,
                resultats: resultForRatio,
                suffix: "\(count)"
            ))
            count += 1
        }
    }
    
    private func retrieveFile(directory path: String) -> [FileDirectoryInfo] {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: path)
        var fileInfos: [FileDirectoryInfo] = []
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            
            for fileURL in contents {
                switch fileURL.pathExtension {
                case "jpg", "jpeg", "png":
                    // To do: faire une journalisation pour les erreurs de ce type
                    //let nsImage = NSImage(contentsOfFile: fileURL.path)!  -> plante
                    let nsImage: NSImage? = NSImage(contentsOfFile: fileURL.path)
                        
                    if let rep = nsImage?.representations.first as? NSBitmapImageRep {
                        fileInfos.append(
                            FileDirectoryInfo(
                                filename: fileURL.lastPathComponent,
                                width: rep.pixelsWide,
                                height: rep.pixelsHigh,
                                ratio: Double(rep.pixelsWide) / Double(rep.pixelsHigh)
                            )
                        )
                    } else {
                        // To do - journaliser l'erreur
                        print("Erreur lors de la conversion de l'image en NSBitmapImageRep")
                        print(fileURL.path)
                    }
                    break
                default:
                    continue
                }
            }
            
        }
        catch {
            print("Erreur lors de la lecture du répertoire : \(error)")
        }
        
        return fileInfos
    }
    
    private func openPresenterIndexFile(fullpath path: String) -> PresenterFileIndex? {
        let url = URL(fileURLWithPath: path)

        do {
            let data = try Data(contentsOf: url)
            let indexFile = try JSONDecoder().decode(PresenterFileIndex.self, from: data)
            return indexFile
        } catch {
            print("Erreur : \(error)")
            return nil
        }
    }
    
    private func getNbOfPhotos() -> Int {
        var nbPhoto = 0;

        directoriesInfo.forEach { directoryInfo in
            if directoryInfo.isChecked {
                nbPhoto += directoryInfo.fileInfos.count
            }
        }
        
        return nbPhoto;
    }
    
    private func getNbOfPhotoInResultat() -> Int {
        var nbPhoto = 0;

        analysisResultats.forEach { analysisResultat in
            if analysisResultat.isChecked {
                nbPhoto += analysisResultat.NbOfFiles()
            }
        }
        
        return nbPhoto;
    }
    
    private func getPourcentage(
        quotient: Int,
        diviseur: Int
    ) -> Double {
        return diviseur == 0 ? 0 : Double(quotient) / Double(diviseur)
    }
    
    private func selectDirectory() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.prompt = "Choisir"

        let response = panel.runModal()
        return response == .OK ? panel.url : nil
    }
    
    private func formatNombre(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "   // espace entre les milliers
        formatter.groupingSize = 3
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
        
    PhotoPresenterFactoryView(
        dirInfos: [
            DirectoryInfo(path: "directory 1"),
            DirectoryInfo(path: "directory 2"),
            DirectoryInfo(isChecked: true, path: "directory 3"),
            DirectoryInfo(path: "directory 4"),
        ]
    )
}
