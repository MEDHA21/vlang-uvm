//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc. 
//   Copyright 2010 Synopsys, Inc.
//   Copyright 2014 Coverify Systems Technology
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//------------------------------------------------------------------------------

module uvm.seq.uvm_push_sequencer;
import uvm.seq.uvm_sequence_item;
import uvm.seq.uvm_sequencer_param_base;

import uvm.meta.misc;
import uvm.base.uvm_component;

import uvm.tlm1.uvm_ports;

//------------------------------------------------------------------------------
//
// CLASS: uvm_push_sequencer #(REQ,RSP)
//
//------------------------------------------------------------------------------

class uvm_push_sequencer(REQ=uvm_sequence_item, RSP=REQ):
  uvm_sequencer_param_base!(REQ, RSP)
{
  mixin(uvm_sync!uvm_push_sequencer);

  alias uvm_push_sequencer!(REQ , RSP) this_type;

  // Port: req_port
  //
  // The push sequencer requires access to a blocking put interface.
  // A continuous stream of sequence items are sent out this port, based on
  // the list of available sequences loaded into this sequencer.
  //
  @uvm_immutable_sync
    private uvm_blocking_put_port!REQ _req_port;


  // Function: new
  //
  // Standard component constructor that creates an instance of this class
  // using the given ~name~ and ~parent~, if any.
  //
  public this(string name, uvm_component parent = null) {
    synchronized(this) {
      super(name, parent);
      req_port = new uvm_blocking_put_port!REQ ("req_port", this);
    }
  }

  // Task: run_phase
  //
  // The push sequencer continuously selects from its list of available
  // sequences and sends the next item from the selected sequence out its
  // <req_port> using req_port.put(item). Typically, the req_port would be
  // connected to the req_export on an instance of an
  // <uvm_push_driver #(REQ,RSP)>, which would be responsible for
  // executing the item.
  //
  override public void run_phase(uvm_phase phase) {

    // viriable selected_sequence declared in SV version -- but seems unused
    // int selected_sequence;

    auto runF = fork({
	super.run_phase(phase);
	while(true) {
	  REQ t;
          m_select_sequence();
          m_req_fifo.get(t);
          req_port.put(t);
          m_wait_for_item_sequence_id = t.get_sequence_id();
          m_wait_for_item_transaction_id = t.get_transaction_id();
	}
      });
    runF.joinAll();
  }

  protected int  m_find_number_driver_connections() {
    return req_port.size();
  }

}
