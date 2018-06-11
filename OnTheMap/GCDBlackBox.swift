//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Marcela Ceneviva Auslenter on 11/06/2018.
//  Copyright © 2018 Marcela Ceneviva Auslenter. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
