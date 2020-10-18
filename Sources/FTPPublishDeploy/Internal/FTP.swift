/**
*  FTPPublishDeploy
*  Copyright (c) Brian Dinsen 2020
*  MIT license, see LICENSE file for details
*/

import Publish
import ShellOut
import Files
import Foundation

struct FTP<Site: Website> {
    let connection: FTPConnection
    let context: PublishingContext<Site>
    let path: String
    let sourcePath: String?
    let subfolderPath: String?
    let useSSL: Bool

    func uploadFile() throws {
        if let subfolderPath = self.subfolderPath {
            try uploadSubFile(filePath: self.path,
                              sourcePath: self.sourcePath,
                              subfolderPath: subfolderPath,
                              useSSL: self.useSSL)
        } else {
            try uploadRootFile(filePath: self.path,
                               sourcePath: self.sourcePath,
                               useSSL: self.useSSL)
        }
    }
}

private extension FTP {
    func uploadSubFile(filePath: String,
                       sourcePath: String?,
                       subfolderPath: String,
                       useSSL: Bool = true) throws {
        let usingSSL = useSSL ? "--ftp-ssl" : ""
        do {
            let ftpUrl = "ftp://\(connection.host):\(connection.port)/\(sourcePath != nil ? "\(sourcePath!)/" : "")\(subfolderPath)/"
            try shellOut(
                to: "echo \"\(filePath) -> \(ftpUrl)\"",
                outputHandle: FileHandle.standardOutput,
                errorHandle: FileHandle.standardError
            )
            try shellOut(
                to: """
                    curl -T \(filePath) \
                    \(usingSSL) \
                    -u \(connection.username):\(connection.password) \
                    --ftp-create-dirs \
                    \(ftpUrl)
                """,
                outputHandle: FileHandle.standardOutput,
                errorHandle: FileHandle.standardError
            )
        } catch let error as ShellOutError {
            throw PublishingError(infoMessage: error.message)
        } catch {
            throw error
        }
    }

    func uploadRootFile(filePath: String,
                        sourcePath: String?,
                        useSSL: Bool = true) throws {
        let usingSSL = useSSL ? "--ftp-ssl" : ""
        do {
            let ftpUrl = "ftp://\(connection.host):\(connection.port)/\(sourcePath != nil ? "\(sourcePath!)/" : "")"
            try shellOut(
                to: "echo \"\(filePath) -> \(ftpUrl)\"",
                outputHandle: FileHandle.standardOutput,
                errorHandle: FileHandle.standardError
            )
            try shellOut(
                to: """
                    curl -T \(filePath) \
                    \(usingSSL) \
                    -u \(connection.username):\(connection.password) \
                    \(ftpUrl)
                """,
                outputHandle: FileHandle.standardOutput,
                errorHandle: FileHandle.standardError
            )
        } catch let error as ShellOutError {
            throw PublishingError(infoMessage: error.message)
        } catch {
            throw error
        }
    }
}
