/********************************************************************************
 * Copyright (c) 2019 University of York and others
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Alvaro Miyazawa - initial definition
 ********************************************************************************/

/*
 * generated by Xtext 2.17.1
 */
package circus.robocalc.robochart.textual.ide

import circus.robocalc.robochart.textual.RoboChartRuntimeModule
import circus.robocalc.robochart.textual.RoboChartStandaloneSetup
import com.google.inject.Guice
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class RoboChartIdeSetup extends RoboChartStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new RoboChartRuntimeModule, new RoboChartIdeModule))
	}
	
}
