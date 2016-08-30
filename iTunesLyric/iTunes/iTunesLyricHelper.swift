//
//  iTunesLyricHelper.swift
//  iTunesLyric
//
//  Created by 王宇 on 2016/8/26.
//  Copyright © 2016年 Putotyra. All rights reserved.
//

import Foundation

typealias FetchLyricListCompletion = ([Any]) -> Void

typealias FetchLyricCompletion = (SFLrc?) -> Void

class iTunesLyricHelper {
    
    var requestsDict = Dictionary<String, URLRequest>()
    
    static var shared = iTunesLyricHelper()
    
    /**
     根据iTunes歌曲信息智能获取歌词
     */
    func smartFetchLyric(with song: Song, completion: FetchLyricCompletion) {
        if readSongLyricFromLocal(song: song) {
//            completion(song)
            return
        }
        let key = "fetchLyricWithSong-\(song.filename)"
        if requestsDict[key] != nil {
//            return
        }
        var request = URLRequest(url: URL(string: FetchSongIDURL)!)
        request.setValue(ENET_COOKIE, forHTTPHeaderField: "Cookie")
        request.setValue(ENET_UA, forHTTPHeaderField: "User-Agent")
        request.httpMethod = "POST"
        request.httpBody = SearchQuery(key: song.title).httpBody
        
//        requestsDict[key] = request
        
        print("Start Smart Fetch")
        dump(request)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("Got Smart Response")
            guard error == nil, let data = data, let bodyString = String.init(data: data, encoding: .utf8) else {
                return
            }
            guard let obj = SFJSON(jsonString: bodyString), let songs = obj["result"]["songs"].arrayObject else {
                return
            }
            guard let target = songs.first(where: { $0["artists"].arrayObject?.first?["name"].string == song.artist }) else {
                return
            }
            print("Smart Response OK")
            /*
            let song = Song(title: target["name"].stringValue, artist: target["artists"].arrayObject?.first(where: {
                $0["name"].string != nil
            })?["name"].string ?? "", album: target["album"]["name"].stringValue, neteaseId: target["id"].intValue)!
            */
            song.neteaseId = target["id"].intValue
            print("Got Netease MusicID \(song.neteaseId)")
            self.fetchLyric(with: song, completion: completion)
            
            //FIXME
//            song.lyricId = target.lyricId
            
//            NSString *timeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",song.duration / 60, song.duration % 60];
//            NSLog(@"%@-%@,找到正确的歌曲信息, 时间一致，id=%ld,duration=%@", song.name, song.artist,(long)song.lyricId, timeStr);

        }.resume()
        
        
        // 如果歌曲名字和歌手名都一致则认为是同一首歌
//        for (Song *fetchSong in referenceSongs) {
//        if ([fetchSong.name isEqualToString: song.name] && [fetchSong.artist isEqualToString: song.artist]) {
//        song.lyricId = fetchSong.lyricId;
//        NSString *timeStr = [NSString stringWithFormat:@"%.2ld:%.2ld",song.duration / 60, song.duration % 60];
//        NSLog(@"%@-%@,找到正确的歌曲信息, 时间一致，id=%ld,duration=%@", song.name, song.artist,(long)song.lyricId, timeStr);
//        break;
//        }
//        }
//        
//        if (song.lyricId) {
//        [helper fetchLyricWithSong: song completeBlock:^(Song *song) {
//        block(song);
//        }];
//        } else {
//        block(nil);
//        }
//        [helper.requestsDict removeObjectForKey: key];
//        }];
//        
//        [request setFailedBlock:^{
//        [helper.requestsDict removeObjectForKey: key];
//        }];
//        
//        [request startAsynchronous];
    }
    
    /**
     根据歌曲名查询歌曲歌词列表
     */
    func fetchLyricList(with name: String, completion: FetchLyricListCompletion) {
//        NSString *key = [NSString stringWithFormat: @"fetchLyricWithSong-%@", songName];
//        if ([_requestsDict objectForKey: key]) {
//            return;
//        }
//        
//        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL: [NSURL URLWithString: FETCH_SONG_ID_URL]];
//        [request addPostValue: songName forKey: @"s"];
//        [request addPostValue: @(1) forKey: @"type"];
//        [request addPostValue: @"true" forKey: @"total"];
//        [request addPostValue: @(100) forKey: @"limit"];
//        [request addPostValue: @(0) forKey: @"offset"];
//        [request addPostValue: @"<span class=\"s-fc2\">" forKey: @"hlpretag"];
//        [request addPostValue: @"</span>" forKey: @"hlposttag"];
//        [request addRequestHeader: @"Cookie" value: ENET_COOKIE];
//        [request addRequestHeader: @"User-Agent" value: ENET_UA];
//        request.timeOutSeconds = 5;
//        
//        [_requestsDict setValue: request forKey: key];
//        
//        __weak iTunesLyricHelper *helper = self;
//        [request setCompletionBlock:^{
//        
//        id obj = request.responseString.objectFromJSONString;
//        NSMutableArray *referenceSongs = [NSMutableArray array];
//        NSArray *songsArray = obj[@"result"][@"songs"];
//        for (NSDictionary *songDict in songsArray) {
//        Song *song = [[Song alloc] init];
//        song.name = songDict[@"name"];
//        song.duration = (NSInteger)([songDict[@"duration"] integerValue] / 1000);
//        song.album = songDict[@"album"][@"name"];
//        song.lyricId = [songDict[@"id"] integerValue];
//        song.score = [songDict[@"score"]integerValue];
//        NSArray *artists = songDict[@"artists"];
//        for (NSInteger i = 0; i < artists.count; i++) {
//        NSString *artistName = artists[i][@"name"];
//        if ([artistName length]) {
//        song.artist = artistName;
//        break;
//        }
//        }
//        [referenceSongs addObject: song];
//        }
//        
//        [referenceSongs sortUsingComparator:^NSComparisonResult(Song *song1, Song *song2) {
//        return song1.score < song2.score;
//        }];
//        
//        if (block) {
//        block(referenceSongs);
//        }
//        [helper.requestsDict removeObjectForKey: key];
//        
//        }];
//        
//        [request setFailedBlock:^{
//        if (block) {
//        block(nil);
//        }
//        [helper.requestsDict removeObjectForKey: key];
//        }];
//        
//        [request startAsynchronous];
    }
    
    /**
     根据歌曲（含有歌词id）获取歌词
     */
    func fetchLyric(with song: Song, completion: FetchLyricCompletion) {
        print("Fetching Lyric")
        var request = URLRequest(url: URL(string: "\(FetchSongLyricURL)&id=\(song.neteaseId)")!)
        request.setValue("Cookie", forHTTPHeaderField: ENET_COOKIE)
        request.setValue("User-Agent", forHTTPHeaderField: ENET_UA)

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response as? HTTPURLResponse,
                response.statusCode == 200, let json = SFJSON(data: data) else {
//                completion(nil)
                return
            }
            if let lyric = json["lrc"]["lyric"].string {
                print("\(song.filename), 找到正确的歌词信息")
                let lrc = SFLrcParser(rawLyric: lyric).parse()
//                print(lyrics)
                completion(lrc)
            }
        }.resume()
//        NSString *key = [NSString stringWithFormat: @"_fetchLyricWithSong-%@-%ld", song.name, (long)song.duration];
//        [self.requestsDict setValue: request forKey: key];
//        __weak iTunesLyricHelper *helper = self;
//        request.completionBlock = ^(void){
//            [helper.requestsDict removeObjectForKey: key];
//            id obj = request.responseString.objectFromJSONString;
//            if ([obj[@"code"] integerValue] == 200) {
//                NSString *lyric = obj[@"lrc"][@"lyric"];
//                if (lyric.length) {
//                    song.lyrics = lyric;
//                    [self saveSongLyricToLocal: song];
//                    block(song);
//                } else {
//                    NSLog(@"%@-%@,没有找到正确的歌词信息", song.name, song.artist);
//                    block(nil);
//                }
//            } else {
//                NSLog(@"_fetchLyricWithSong err code %ld, reason: %@", [obj[@"code"] integerValue], obj);
//                block(nil);
//            }
//            
//            [helper.requestsDict removeObjectForKey: key];
//            
//        };
//        [request setFailedBlock:^{
//            NSLog(@"fetch lyric with id error");
//            block(nil);
//            [helper.requestsDict removeObjectForKey: key];
//            }];
//        
//        [request startAsynchronous];
    }
    
    /**
      保存歌词到本地
     */
    func saveSongLyricToLocal(song: Song) {
        guard var lyricPath = lyricCachePath else {
            return
        }
        let filename = "\(song.filename).li"
        lyricPath = (lyricPath as NSString).appendingPathComponent(filename)
        let dict = NSMutableDictionary()
        dict.setValue(song.neteaseId, forKey: "lyricId")
//        dict.setValue(song.lyrics, forKey: "lyrics")
        
        dict.write(toFile: lyricPath, atomically: true)
    }
    
    func readSongLyricFromLocal(song: Song) -> Bool {
        return false
        guard var lyricPath = lyricCachePath else {
            return false
        }
        let filename = "\(song.filename).li"
        lyricPath = (lyricPath as NSString).appendingPathComponent(filename)
        if let dic = NSDictionary(contentsOfFile: lyricPath) {
            song.neteaseId = dic.object(forKey: "lyricId") as! Int
//            song.lyrics = dic["lyrics"] as? String
            return true
        }
        return false
    }
    
    var homePath: String? {
        let userInfoPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.applicationSupportDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!.appending("/iTunesLyric/")
        if FileManager.default.fileExists(atPath: userInfoPath) {
            return userInfoPath
        }else {
            do {
                try FileManager.default.createDirectory(atPath: userInfoPath, withIntermediateDirectories: true, attributes: nil)
                return userInfoPath
            } catch let error as NSError {
                NSLog("home path create error; \(error)")
                return nil
            }
        }
    }

    var lyricCachePath: String? {
        if let userHomePath = homePath {
            let userCachePath = (userHomePath as NSString).appendingPathComponent("lyrics")
            if !FileManager.default.fileExists(atPath: userCachePath) {
                do {
                    try FileManager.default.createDirectory(atPath: userCachePath, withIntermediateDirectories: true, attributes: nil)
                } catch let error as NSError {
                    NSLog("home path create error; \(error)")
                    return nil
                }
            }
            return userCachePath
        }
        return nil
    }

}
